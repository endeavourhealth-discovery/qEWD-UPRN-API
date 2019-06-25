module.exports = function (args, finished) {

  let adrec = args.req.query.adrec;
  let qpost = args.req.query.qpost;
  let orgpost = args.req.query.orgpost;
  let country = args.req.query.country;
  let summary = args.req.query.summary;
  
  console.log(adrec);

  var temp = new this.documentStore.DocumentNode('temp', [process.pid]);
  temp.delete();

  var result = this.db.function({ function: 'GETUPRN^UPRNHOOK', arguments: [adrec, qpost, orgpost, country, summary] });

  var obj = temp.getDocument();

  j = obj[1];
  console.log(j);
  obj = JSON.parse(j);

  finished({
    obj
  });
};