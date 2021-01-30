/**
 * @param {*} event
 */
exports.handler = async (event) => {
  console.log('%j', event)
  return {
    name: event.name.toUpperCase()
  }
}
