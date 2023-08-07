const mongoose = require('mongoose')
const playerSchema = require('./Player');

const gameSchema = new mongoose.Schema({
    player1: {
        type: playerSchema
    },
    player2: {
        type: playerSchema
    },
    isRoomJoinable: {
        type: Boolean,
        default: true
    },
    roomCode: {
        type: String
    },
})

const gameModel = mongoose.model("Game", gameSchema);
module.exports = gameModel;