/**
 * Created by Rodrigo on 21/05/15.
 */
var express = require('express'),
    router = express.Router(),
    mongoose = require('mongoose'),
    bodyParser = require('body-parser'),
    methodOverride = require('method-override'),
    async = require('async'),
    nconf = require('nconf'),
    AWS = require('aws-sdk'),
    request = require('request').defaults({encoding: null}),
    crypto = require('crypto'),
    fs = require('fs-extra'),
    multer = require('multer');


var creds = JSON.parse(fs.readFileSync('./../creds.json', 'utf8'));
var S3accessKeyId = creds.accessKeyId,
    S3secretAccessKey = creds.secretAccessKey,
    S3region = creds.region,
    S3endpoint = creds.endpoint,
    S3bucketname = creds.bucketname,
    S3username = creds.username;

var s3 = AWS.config.update({
    "username": S3username,
    "accessKeyId": S3accessKeyId,
    "secretAccessKey": S3secretAccessKey,
    "region": S3region
});

//use this for ALL requests
router.use(bodyParser.urlencoded({extended: true, limit: 100000000}));
router.use(multer({
    dest: './uploads/',
    rename: function (fieldname, filename) {
        return filename.replace(/\W+/g, '-').toLowerCase() + Date.now()
    },
    limits: {fileSize: 10 * 1024 * 1024}
}))
router.use(methodOverride(function (req, res) {
    if (req.body && typeof req.body === 'object' && '_method' in req.body) {
        // look in urlencoded POST bodies and delete it
        var method = req.body._method;
        delete req.body._method;
        return method
    }
}));

//get the index page that shows everything
router.route('/')
    .get(function (req, res) {
        //get all records and sort by lastname
        mongoose.model('Photo').find({}, null, {sort: {owner: 1}}, function (err, photos) {
            if (err) {
                return console.error(err);
            } else {
                res.format({
                    html: function () {
                        res.render('photos/index', {
                            title: "Everyone's Info",
                            "photos": photos //all photos and use dot notation for attributes for each
                        });
                    },
                    json: function () {
                        res.json(photos);
                    }
                });
            }
        });
    });


router.route('/upload').post(function (req, res) {
    // Get our form values. These rely on the "name" attributes. Used to create new records/documents in MongoDB


    var owner = req.body.owner;
    var timestamp = (new Date).getTime();
    var buf = req.files.photo.path;
    var friends = req.body.friends;

    //uniqueurl concatenates fname, lname, and iterator and removes whitespaces
    var uniqueurlSeed = owner.replace(/\s+/g, '') + String(timestamp);
    var uniqueurl = crypto.createHash('sha1').update(uniqueurlSeed).digest('hex');
    console.log('Trying: ' + uniqueurl);

    //set the goodurl to true so it won't run again
    mongoose.model('Photo').create({
        owner: owner,
        timestamp: timestamp,
        uniqueurl: uniqueurl
    }, function (err, photo) {
        if (err) {
            console.log(err);
            //return handleError(err);
            res.send("There was a problem adding the information to the database.");
        } else {
            console.log('POST creating new photo: ' + photo);
            request.post({
                url: "http://127.0.0.1:3000/photos/upload/" + uniqueurl,
                body: {
                    photo: photo,
                    photobuf: buf,
                    friends: friends
                },
                json: true
            }, function (error, response, body) {
                console.log(body);


            });

        }
    });

    res.format({

        json: function () {
            res.json({success: true});
        },

        html: function () {

            /* If it worked, set the header so the address bar doesn't still say /adduser
             res.location("Photo Booth Registration Success");
             // And forward to success page*/
            res.redirect("/photos");
        }
    });


});

/* GET New Photo page. */
router.get('/new', function (req, res) {
    res.render('photos/new', {title: 'Upload New Photo'});
});


/* POST Add Picture to ECS/S3 */
router.post('/upload/:uniqueurl', function (req, res) {
    console.log(req.body)
    var friends = JSON.parse(req.body.friends);
    var uniqueurl = req.params.uniqueurl;
    var photo = req.body.photo;

    fs.readFile(req.body.photobuf, function (err, data) {
        var buffer = new Buffer(data);

        var s3 = new AWS.S3({endpoint: S3endpoint});
        var params = {
            Bucket: S3bucketname,
            Key: uniqueurl + '.jpeg',
            Body: buffer,
            ACL: 'public-read',
            ContentType: 'image/jpeg'
        };
        s3.putObject(params, function (err, data) {
            if (err) {
                console.log(err, err.stack); // an error occurred
            }
            else {
                console.log(data);// successful response
            }
        });
    });

    async.each(friends,
        function (item, callback) {
            console.log(item);
            mongoose.model('User').findOneAndUpdate(
                {username: item},
                {$push: {'photos': photo._id}},
                {upsert: false},
                function (err, model) {
                    console.log(model);
                }, callback()
            );
        },
        function (err) {
            // All tasks are done now
            if (err) {
                console.log(err);
            }
            else {
                console.log("callback")

            }
        }
    );


    res.format({
        json: function () {
            res.json({success: true});
        }
    });


});

/* GET photo by uniqueurl */
router.get('/:uniqueurl', function (req, res) {
    console.log('getting photo from amazon');


    mongoose.model('Photo').findOne({uniqueurl: req.params.uniqueurl}, function (err) {


        //get the image from S3/ECS that will post a photo to twitter as well
        request.get('http://'+ S3bucketname + S3endpoint +'.amazonaws.com/' + req.params.uniqueurl + '.jpeg', function (error, response, body) {
            if (!error && response.statusCode == 200) {
                console.log(body);
                res.send(body);
            }
            else {
                res.send(error);
            }

        });


    });

});

/* GET photos by username */
router.get('/users/:username', function (req, res) {
    console.log("Getting " + req.params.username);

    async.waterfall([
            function (callback) {

                mongoose.model('User').findOne({username: req.params.username}, function (err, user) {

                    callback(null, user);
                });

            },

            function (user, callback) {
                async.map(user.photos, getPhotos, function (err, photos) {
                    if (!err) {
                        callback(null, user, photos);
                    } else {
                        console.log('Error: ' + err);
                    }

                });


                function getPhotos(id, done) {
                    mongoose.model('Photo').find({
                        _id: id,
                        timestamp: {$gt: user.timestamp}
                    },'uniqueurl owner', function (err, photo) {
                        return done(null, photo);
                    });
                }
            },

            function (user, photos, callback) {
                var date = new Date;
                console.log("\nDate (old): " + user.timestamp + " Date (new): " + date + "\n\n");
                mongoose.model('User').update({username: user.username},
                    {timestamp: date}, {upsert: true, safe: false},
                    function (err, model) {
                        if (err) {
                            console.log(err);
                        }
                    });
                callback(null, photos);

            }],

        function (err, photos) {
            res.format({
                text: function () {
                    res.send(photos);
                }
            });
        }
    )
    ;


});


// route middleware to validate :uniqueurl
router.param('uniqueurl', function (req, res, next, uniqueurl) {
    //console.log('validating ' + uniqueurl + ' exists');
    mongoose.model('Photo').findOne({uniqueurl: uniqueurl}, function (err, photo) {
        if (err) {
            console.log(uniqueurl + ' was not found');
            res.status(404);
            var err = new Error('Not Found');
            err.status = 404;
            res.format({

                json: function () {
                    res.json({message: err.status + ' ' + err});
                }
            });
        } else if (photo === null) {
            console.log(uniqueurl + ' was not found');
            res.status(404);
            var err = new Error('Not Found');
            err.status = 404;
            res.format({
                html: function () {
                    next(err);
                },
                json: function () {
                    res.json({message: err.status + ' ' + err});
                }
            });
        } else {
            //console.log(photo);
            // once validation is done save the new item in the req
            req.uniqueurl = uniqueurl;
            // go to the next thing
            next();
        }
    });
});

// route middleware to validate :username
router.param('username', function (req, res, next, username) {

    mongoose.model('User').findOne({username: username}, function (err, user) {
        if (err) {
            console.log(username + ' not found');
            res.status(404);
            var err = new Error('Not Found');
            err.status = 404;
            res.format({

                json: function () {
                    res.json({message: err.status + ' ' + err});
                }
            });
        } else if (user === null) {
            console.log(username + ' was not found');
            res.status(404);
            var err = new Error('Not Found');
            err.status = 404;
            res.format({
                html: function () {
                    next(err);
                },
                json: function () {
                    res.json({message: err.status + ' ' + err});
                }
            });
        } else {

            req.username = username;
            // go to the next thing
            next();
        }
    });
});

module.exports = router;