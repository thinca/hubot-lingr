splitStrings = (strings, limit) ->
  splitPat = new RegExp("[^]{1,#{limit}}", 'g')
  nl = "\n"
  allLines = strings.join(nl).split(nl)
  p = 0
  arraysOfParts =
    while p < allLines.length
      chars = 0
      base = p
      while p < allLines.length and chars + allLines[p].length < limit
        chars += allLines[p].length + nl.length
        p++
      allLines.slice(base, p).join(nl).match(splitPat)
  [].concat(arraysOfParts...)

module.exports = splitStrings
