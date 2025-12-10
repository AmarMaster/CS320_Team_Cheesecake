require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const pgp = require('pg-promise')();

const connectionString = process.env.DATABASE_URL || `postgres://${process.env.PG_USER}:${process.env.PG_PASSWORD}@${process.env.PG_HOST}:${process.env.PG_PORT}/${process.env.PG_DATABASE}`;

const db = pgp(connectionString);

module.exports = db;