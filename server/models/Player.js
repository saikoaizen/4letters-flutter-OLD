const mongoose = require('mongoose')

const playerSchema = new mongoose.Schema({
    name: {
        type: String
    },
    isPartyLeader: {
        type: Boolean,
        default: false
    },
    socketID: {
        type: String
    },
    secretWord: {
        type: String
    }
})

module.exports = playerSchema;