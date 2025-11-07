import mysql from 'mysql2';
import dotenv from 'dotenv';
dotenv.config();

const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
}).promise();

export async function getUsers() {
    const rows = await pool.query('SELECT * FROM users')
    return rows;
};

export async function getUser(id) {
    const rows = await pool.query(`
    SELECT * 
    FROM users 
    WHERE id = ?`, [id]);
    return rows;
};

export async function createUser(username, email, passwordHash, userRole, createdBy) {
    const userStatus = 'Activo'; 
    
    const [result] = await pool.query(`
        INSERT INTO users 
        (username, email, password_hash, user_role, user_status, created_by)
        VALUES (?, ?, ?, ?, ?, ?)
    `, [
        username,
        email,
        passwordHash, 
        userRole,     
        userStatus,   
        createdBy     
    ]);
    const id = result.insertId;
    return getUser(id);
}
