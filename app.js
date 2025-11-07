import express from 'express'
// 1. Importar las funciones de consulta de la base de datos
import { getUsers } from './database.js'; 
// import adminRouter from './routes/admin.js'; 

const app = express()
const PORT = 8080;

// Middleware para parsear JSON (Necesario para POST/PUT)
app.use(express.json());

// 1. Ruta de Prueba/Raíz (Añadida para confirmar que el servidor funciona)
app.get("/", (req, res) => {
    res.send("Bienvenido a la API IMC App.");
});

// 2. Ruta de Usuarios (Ruta ASÍNCRONA que usa la BD)
app.get("/users", async (req, res) => {
    const users = await getUsers();
    res.send(users);
});

// 3. Cargar Rutas de Administración
// app.use('/api/admin', adminRouter); 


// 4. Middleware de Manejo de Errores (Siempre al final)
app.use((err, req, res, next) => {
    console.error(err.stack);
    // Enviamos una respuesta más informativa
    res.status(500).json({
        message: 'server error.',
        error: process.env.NODE_ENV === 'production' ? null : err.message
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Servidor Express iniciado en http://localhost:${PORT}`);
    console.log(`Prueba la lista de usuarios: http://localhost:${PORT}/users`);
});