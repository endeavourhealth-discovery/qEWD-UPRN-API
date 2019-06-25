module.exports = function (args, finished) {
  var username = args.req.body.username;
  var password = args.req.body.password;
  var jwt = args.session;

  // audit login
  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: '^DS', arguments: [username + '~' + password] });
  var outputs = temp.getDocument();

  console.log(JSON.stringify(outputs));

  if (username === 'rob' && password === 'secret') {
    jwt.userText = 'Welcome Rob';
    jwt.username = username;
    jwt.authenticated = true;
    jwt.timeout = 1200;
    finished({ ok: true });
  }
  else {
    finished({ error: 'Invalid login' });
  }
};