import express from 'express';
import { Pool } from 'pg';

const server = express();
const port = 3000;


import { createSSRApp } from 'vue'

export function createApp() {
  return createSSRApp({
    data: () => ({ count: 1 }),
    template: `<button @click="count++">{{ count }}</button>`
  })
}

const pool = new Pool({
  user: 'myuser',
  host: 'postgres',
  database: 'mydb',
  password: 'mypass',
  port: 5432,
});


async function getArticleById(id) {
  const result = await pool.query('SELECT * FROM articles WHERE id = $1', [id]);
  return result.rows[0];
}


server.get('/articles/:articleId', async (req, res) => {
  console.log("В обработчике")
  try {
    const articleId = req.params.articleId;
    const articleData = await getArticleById(articleId);

    
    if (!articleData) {
      return res.status(404).send('Article not found');
    }

    const app = createApp();
    // const html = await renderToString(app);
    //           <div id="app">${html}</div>

    const fullHTML = `
      <!DOCTYPE html>
      <html>
        <head>
          ${articleData.head}
        </head>
        <body>
          <div id="app2">${articleData.content}</div>
        </body>
      </html>
    `;
    
    res.send(fullHTML);
  } catch (err) {
    console.error(err);
    res.status(500).send('Internal Server Error');
  }
});



server.use(express.static('.'));

server.listen(port, () => {
    console.log(`Сервер запущен на http://localhost:${port}/articles/1`);
});
