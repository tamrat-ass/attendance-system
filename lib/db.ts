import { sql } from '@vercel/postgres';

export const db = {
  query: async (text: string, params?: any[]) => {
    try {
      // Convert MySQL-style ? placeholders to PostgreSQL $1, $2, etc.
      let index = 0;
      const pgQuery = text.replace(/\?/g, () => `$${++index}`);
      
      const result = await sql.query(pgQuery, params || []);
      return [result.rows];
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  },
  execute: async (text: string, params?: any[]) => {
    try {
      // Convert MySQL-style ? placeholders to PostgreSQL $1, $2, etc.
      let index = 0;
      const pgQuery = text.replace(/\?/g, () => `$${++index}`);
      
      const result = await sql.query(pgQuery, params || []);
      return [result];
    } catch (error) {
      console.error('Database execute error:', error);
      throw error;
    }
  }
};