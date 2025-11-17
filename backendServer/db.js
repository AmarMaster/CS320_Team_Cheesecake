const { Pool } = require('pg');

const db = new Pool({
    user: 'archer',
    host: 'localhost',
    database: 'eventtracker-db',
    port: 5432,
});

module.exports = {
    query: (text, params) => db.query(text, params),
};