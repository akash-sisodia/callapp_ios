//
//  Server.js
//  CallApp
//
//  Created by Akash Singh Sisodia on 06/21/20.
//  Copyright © 2020 Akash Singh Sisodia. All rights reserved.
//


(function () {
  'use strict';
  var express = require('express');
  var app = express();
  var http = require('http').Server(app);
  var io = require('socket.io')(http);

  var rooms = {};

  app.get('/', function (req, res) {
    res.send('<h1>RTC Peer connection signaling</h1>');
  });

  http.listen(3000, function () {
    console.log('Listening on *:3000');
  });

  io.sockets.on('connection', function (socket) {
    console.log('New socket connection.');

    socket.on('join_room', function (message) {
      var room = message.room || '';
      var connections = rooms[room] = rooms[room] || [];

      if (connections.length < 2) {
        socket.join(room);

        socket.broadcast.to(room).emit('new_peer', {
          socketId: socket.id
        });

        connections.push(socket);

        var connectionsId = [];
        for (var i = 0, len = connections.length; i < len; i++) {
          var id = connections[i].id;

          if (id !== socket.id) {
            connectionsId.push(id);
          }
        }

        socket.on('disconnect', function () {
          endConnection(room, socket);
        });

        function endConnection(room, socket) {
          var connections = rooms[room];
          for (var i = 0; i < connections.length; i++) {
            var id = connections[i].id;
            if (id === socket.id) {
              connections.splice(i, 1);
              i--;

              socket.broadcast.to(room).emit('peer_left', { "message": "Your opponent is left from session." });
              socket.leave(room);
            }
          }
        }

        socket.on('end_call', function (data) {
          endConnection(data.room, socket);
        });

        socket.on('ice_candidate', function (data) {
          var client = getSocket(data.room, data.socketId);
          if (client) {
            client.emit('ice_candidate', {
              label: data.label,
              candidate: data.candidate,
              socketId: socket.id
            });
          }
        });

        socket.on('send_offer', function (data) {
          var client = getSocket(data.room, data.socketId);
          if (client) {
            client.emit('receive_offer', { sdp: data.sdp, socketId: socket.id });
          }
        });

        socket.on('send_answer', function (data) {
          var client = getSocket(data.room, data.socketId);
          if (client) {
            client.emit('receive_answer', { sdp: data.sdp, socketId: socket.id });
          }
        });
      } else {
        socket.emit('room_full', { socketId: socket.id });
      }
    });
  });

  function getSocket(room, id) {
    var connections = rooms[room];
    if (!connections) {
      return;
    }

    for (var i = 0; i < connections.length; i++) {
      var socket = connections[i];
      if (id === socket.id) {
        return socket;
      }
    }
  }
})();
