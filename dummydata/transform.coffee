fs = require "fs"
plv8 = require "./plv8"
newpoints = require "./newPointdata"

plv8.areas = newpoints.areas
console.log plv8.areas

fs.writeFileSync "./plv82.json", JSON.stringify(plv8);