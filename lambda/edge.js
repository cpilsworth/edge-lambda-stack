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
  const params = {
    FunctionName: context.functionName.replace('-edge-', '-vpc-'),
    Payload: JSON.stringify({ name: 'edge-vpc' })
  }
  console.log('%j', params)
  const vpcResponse = await lambda.invoke(params)
    .promise()

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
