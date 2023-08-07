const express = require('express');
const http = require('http');
const Game = require('./models/Game');
const mongoose = require("mongoose");
const fs = require('fs');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
var io = require('socket.io')(server);

app.use(express.json());

// connect to mongodb
const DB = process.env.ENDPOINT;


// Set of all possible room codes
const allRoomCodes = new Set(Array.from({ length: 1000000 }, (_, i) => String(i).padStart(6, '0')));

// Set to track used room codes
const usedRoomCodes = new Set();

// Generate a unique 6-digit room code
function generateRoomCode() {
  if (allRoomCodes.size === usedRoomCodes.size) {
    throw new Error('No available room codes');
  }

  let code;
  do {
    const randomIndex = Math.floor(Math.random() * allRoomCodes.size);
    code = Array.from(allRoomCodes)[randomIndex];
  } while (usedRoomCodes.has(code));

  usedRoomCodes.add(code);
  return code;
}

// Generating the wordlist's hashmap from JSON to validate user input
const wordMap = {};
const wordsData = fs.readFileSync("data/words.json");
const words = JSON.parse(wordsData);
for (const word in words) {
  if (words.hasOwnProperty(word)) {
    wordMap[word] = true;
  }
}


io.on("connection", (socket)=>{
  //Creating a room and joining it
  socket.on('create-room', async (name) => {
    console.log("Asking to create")
    try{
      let game = new Game();

      let player = {
        socketID: socket.id,  
        name,
        isPartyLeader: true
      };

      game.player1 = player;
      game.roomCode = generateRoomCode();

      game = await game.save();

      socket.join(game.roomCode);
      console.log(`${name} created ${game.roomCode}`);
      socket.emit('createdRoom', game.roomCode);
    }
    catch(e){
      console.log(e);
    }
  });

  //Joining a pre-existing room
  socket.on('join-room', async (data)=>{
    try{
      if(io.sockets.adapter.rooms.has(data.roomCode)){
        let game = await Game.findOne({roomCode: data.roomCode});

        if(game.isRoomJoinable==false){
          console.log("Room can't be joined!");
          socket.emit('roomJoinError', "Room can't be joined");
          return Error("Room can't be joined");
        }

        let player = {
          name: data.name,
          socketID: socket.id,
          isPartyLeader: false,
        };
        const res = await Game.updateOne({roomCode: game.roomCode}, {
          $set: {
            player2: player,
            isRoomJoinable: false
          }
        });

        socket.join(data.roomCode);
        console.log(`${data.name} joined ${data.roomCode}`);
        socket.emit('joinedRoom', {'roomCode': data.roomCode, 'opponentName': game.player1.name});
        io.to(game.roomCode).emit('opponentJoined', data.name);
      }
      //Wrong roomCode
      else{
        socket.emit('roomJoinError', 'Please enter a valid code!');
      }
    }
    catch(e){
      socket.emit('roomJoinError', e);
    }
  });

  //Starting the game
  socket.on('start-game', async (roomCode)=>{
    let game = await Game.findOne({roomCode});
    if(game.player1.socketID==socket.id){
      io.to(game.roomCode).emit('startedGame');
    }
  });

  //Getting the secret word
  socket.on('submit-secret-word', async (data) =>{

    if(wordMap[data.secretWord]==true){
      let game = await Game.findOne({roomCode: data.roomCode});
      let player;

      if(game.player1.socketID==socket.id){
        player = game.player1;
        player.secretWord = data.secretWord;
          const res = await Game.updateOne({roomCode: game.roomCode}, {
            $set: {
              player1: player
            }
          });
      }
      else{
        player = game.player2;
        player.secretWord = data.secretWord;
          const res = await Game.updateOne({roomCode: game.roomCode}, {
            $set: {
              player2: player
            }
          });
      }

      socket.emit('submitted-secret-word');
      if(game.player1.secretWord != undefined && game.player2.secretWord != undefined && game.player1.secretWord != '' && game.player2.secretWord != ''){
        io.to(data.roomCode).emit('begin-session');
      }
    }
    else{
      socket.emit('wordSubmitError', 'Please use a valid word!');
    }
  })

  //Handling the guesses
  socket.on('submit-guess', async (data)=>{

    if(wordMap[data.guess]==true){

      const game = await Game.findOne({roomCode: data.roomCode});
      let count = 0;
      let secretWord = game.player1.socketID==socket.id ? game.player2.secretWord: game.player1.secretWord;
      let player = game.player1.socketID==socket.id ? game.player1: game.player2;

      if(secretWord==data.guess){
        console.log(`WINNER WINNER ${player.name}`);
        io.to(data.roomCode).emit('game-over', player.name);
        return;
      }

      for(let i=0; i<4; i++){
        if(secretWord.includes(data.guess[i])) count+=1;
      }
      
      io.to(data.roomCode).emit('guess-response', {count: count, guess: data.guess});
    }
    else{
      socket.emit('wordSubmitError', 'Please use a valid word!');
    }})
    
  // Leaving a room
  socket.on('leave-room', async (roomCode) => {
    try {
      const game = await Game.findOne({ roomCode });

      // Identify the player who wants to leave
      const player = game.player1.socketID === socket.id ? game.player1 : game.player2;

      // Remove the player from the game
      if (game.player1.socketID === socket.id) {
        game.player1 = game.player2;
        game.player1.isPartyLeader = true;
      }
      game.player2 = null;

      game.isRoomJoinable = true;

      await game.save();

      // Notify other players in the room
      socket.to(roomCode).emit('player-left', player.name);

      // Check if there are no more players in the game
      if (!game.player1 && !game.player2) {
        // Clean up the game if no players left
        await Game.deleteOne({ roomCode });
        usedRoomCodes.delete(roomCode);
      }
    } catch (error) {
      console.error(error);
    }
  });
})

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection Successful!");
  })
  .catch((e) => {
    console.log(e);
  });

server.listen(port, ()=>{
  console.log(`Listening on port ${server.address.address} ${port}`);
})

console.log(`Listening on port ${server.address.address}`);