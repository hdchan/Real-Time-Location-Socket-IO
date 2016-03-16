var app = require('http').createServer(handler)
var io = require('socket.io')(app);
var fs = require('fs');

var userList = [];

app.listen(3000, function(){
  console.log('Listening on *:3000');
});

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

io.on('connection', function (clientSocket) {
	io.emit('connected', 'testing');
    
	clientSocket.on("connectUser", function(clientNickname) {
		var message = "User " + clientNickname + " was connected.";
		console.log(message);

		var userInfo = {};
		var foundUser = false;
		for (var i=0; i<userList.length; i++) {
			if (userList[i]["nickname"] == clientNickname) {
			  userList[i]["isConnected"] = true
			  userList[i]["id"] = clientSocket.id;
			  userInfo = userList[i];
			  foundUser = true;
			  break;
			}
		}

		if (!foundUser) {
			userInfo["id"] = clientSocket.id;
			userInfo["nickname"] = clientNickname;
			userInfo["isConnected"] = true
			userList.push(userInfo);
		}

		
// 		io.emit("userConnectUpdate", userInfo)
	});

    clientSocket.on("userLocationUpdated", function(coordinates, callback) {
		
		for (var i=0; i<userList.length; i++) {
			if (userList[i]["id"] == clientSocket.id) {
// 			  userList[i]["isConnected"] = true
// 			  userList[i]["id"] = clientSocket.id;
			  userList[i]["coordinates"] = coordinates
// 			  console.log(coordinates)
// 			  userInfo = userList[i];
// 			  foundUser = true;
			  break;
			}
		}
		console.log(userList)
		callback(userList)
//     	io.emit("userList", userList);
    	
    });
    
});