'use strict';
// From https://gist.githubusercontent.com/mootrichard/ac0636683157b5e6a97875389d92f706/raw/e28e4ee6f84197545ab658b153e1ea513b322784/handler.js

const SquareConnect = require('square-connect');

module.exports.checkout = (event, context, callback) => {
  let response = "Success! Our function is running!";
  callback(null, response);
};
