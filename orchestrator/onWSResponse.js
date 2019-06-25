module.exports = function(req, res, next) {

   var msg = res.locals.message || {error: "Internal server error"};

  console.log("*********");
  console.log(msg);
  console.log("*********");

  if (msg.token !== undefined) delete msg.token;

  res.send(msg.obj);

  next();
};