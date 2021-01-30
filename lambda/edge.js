const AWS = require('aws-sdk')
// const { CloudFrontRequestEvent, Context, CloudFrontResultResponse } = require('@types/aws-lambda')

const lambda = new AWS.Lambda()

/**
 *
 * @param {CloudFrontRequestEvent} event
 * @param {Context} context
 * @returns {CloudFrontResultResponse}
 */
exports.handler = async (event, context) => {
  let { functionName } = context;

  const params = {
    FunctionName: vpcLambdaName(functionName),
    Payload: JSON.stringify({ edge: functionName })
  }
  
  const vpcResponse = await lambda.invoke(params).promise();

  return {
    status: 200,
    statusDescription: 'OK',
    body: JSON.stringify(vpcResponse),
    headers: {
      'content-type': [
        { key: 'Content-Type', value: 'application/json' }
      ]
    }
  }
}

/**
 * Calculate the vpc lambda function name from the edge lambda name
 * @param {string} edgeLambdaName 
 */
function vpcLambdaName(edgeLambdaName) {
  return edgeLambdaName.replace('-edge-', '-vpc-');
}