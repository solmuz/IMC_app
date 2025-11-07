import express from 'express'; 
import {getUsers, getUser, createUser} from './database.js';

const app = express(); // Instantiate the Express application

// Define a basic GET route handler
app.get('/users', async(req, res) => {
    // A route MUST send a response back to the client
    const users = await getUsers();
    res.send(users); 
});

// Start the server
app.listen(3000, () => {
});