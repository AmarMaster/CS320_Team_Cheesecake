import { Pool } from 'pg';

const db = new Pool({
    user: 'archer',
    host: 'localhost',
    database: 'eventtracker-db',
    port: 5432,
})

export default {
    query: (text, params) => db.query(text, params),
};