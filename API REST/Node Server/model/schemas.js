var mongoose = require('mongoose');
var photoSchema = new mongoose.Schema({
  owner: {type: String},
  timestamp: { type: Date, default: Date.now },
  uniqueurl: {type: String, unique: true}
});
mongoose.model('Photo', photoSchema);

var userSchema = new mongoose.Schema({  
  username: String,
  phoneNumber: String,
  password: String,
  timestamp: { type: Date, default: Date.now },
  photos: [mongoose.Schema.ObjectId]
});
mongoose.model('User', userSchema);