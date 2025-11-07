import mysql from 'mysql2/promise'; // Usar /promise para async/await
import dotenv from 'dotenv';
dotenv.config();

// Inicialización del Pool de Conexiones
const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE
}); // No se usa .promise() al final si ya usas mysql2/promise, pero es válido si pool es el que tiene .promise()

// Funciones de Consulta
export async function getUsers() {
    const [rows] = await pool.query("SELECT * FROM users");
    return rows;
}
export async function getUser(id) {
    // Al usar mysql2/promise, query devuelve un array: [rows, fields]
    const [rows] = await pool.query(`
    SELECT * FROM users
    WHERE id = ?`, [id]);
    // Generalmente quieres devolver solo la primera fila si buscas por ID
    return rows[0]; 
}

export async function addUser(username, email, passwordHash, userRole, createdBy) {
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

    return {
        id: result.insertId,
        username,
        email
    };
}