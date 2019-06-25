module.exports = function (args, finished) {

  //let str = args.req.query.str;
  //console.log(str);

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'STATUS^DS', arguments: [] });

  var obj = temp.getDocument();

  j = obj[1];
  console.log(j);
  obj = JSON.parse(j);

  finished({
    obj
  });
};