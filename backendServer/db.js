require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const pgPromise = require('pg-promise');
const pgp = pgPromise();

// Define the connection configuration object using the environment variables
const dbConfig = {
    user: process.env.PG_USER,
    host: process.env.PG_HOST,
    database: process.env.PG_DATABASE,
    password: process.env.PG_PASSWORD,
    port: process.env.PG_PORT,
    ssl: {
        // This is where you use the environment variable
        rejectUnauthorized: false
    }
};

// You pass the configuration object directly to pgp()
const db = pgp(dbConfig);

module.exports = db;