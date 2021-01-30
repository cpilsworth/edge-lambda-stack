/**
 * @param {*} event
 */
exports.handler = async (event, context) => {
  console.log('%j', event)
  return {
    ...event,
    vpc: context.functionName
  }
}
