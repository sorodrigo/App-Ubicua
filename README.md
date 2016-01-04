# App-Ubicua
iOS app that lets the user take a picture and immediately share it with his friends without loosing a lot of image quality. An example API REST server was developed for this project using Node.js, Express 4 and Amazon Web Services' S3.

Project for Computación Ubicua course in the E.T.S.I.S.I. belonging to the U.P.M. (Technical University of Madrid).

Developed By: Rodrigo Solís.

## Installation

Make a file named creds.json with your Amazon S3 access information in the following format:
<pre><code>{
"accessKeyId": "",
"secretAccessKey": "",
"endpoint": "",
"region": "",
"bucketname": "",
"S3username": ""
}</pre></code>

Configure a Node.js server using the package.json file located inside the Node Server folder and include all files contained in the same folder.

Finally set the BASE_URL to the correspondent value in the Swift project's file named APIHelper.swift.
