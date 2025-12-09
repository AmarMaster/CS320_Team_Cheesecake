const app = require('./app');
const port = 3000;

app.listen(port, () => {
  console.log(`EventMapper backend listening on port ${port}`)
})