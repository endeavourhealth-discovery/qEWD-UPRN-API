module.exports = function (args, finished) {
  var folder = args.req.body.folder;

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  //var result = this.db.function({ function: 'LOAD^DS', arguments: [folder] });
  
  var result = this.db.function({ function: 'LOAD^UPRNMGR', arguments: [folder] });
  var outputs = temp.getDocument();
  
  var obj = temp.getDocument();

  j = obj[1];
  console.log(j);
  obj = JSON.parse(j);

  finished({
    obj
  });
};