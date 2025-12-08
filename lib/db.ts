import mysql from 'mysql2/promise';

// Create connection pool
const pool = mysql.createPool({
  host: process.env.DATABASE_HOST,
  user: process.env.DATABASE_USERNAME,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
  port: parseInt(process.env.DATABASE_PORT || '3306'),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  ...(process.env.NODE_ENV === 'production' && { ssl: { rejectUnauthorized: false } })
});

export const db = {
  query: async (text: string, params?: any[]) => {
    try {
      const [rows] = await pool.execute(text, params || []);
      return [rows];
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  },
  execute: async (text: string, params?: any[]) => {
    try {
      const result = await pool.execute(text, params || []);
      return [result];
    } catch (error) {
      console.error('Database execute error:', error);
      throw error;
    }
  }
};