import mysql from 'mysql2';

const pool = mysql.createPool({
    host: '127.0.0.1',
    user: 'root',
    password: 'Admin',
    database: 'imc_app'
}).promise();

const [rows] = await pool.query("SELECT * FROM users");
console.log(rows);