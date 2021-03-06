"use strict"

path = require 'path'
fs =   require 'fs'

requirejs = require 'requirejs'
logger =  require 'logmimosa'

class Optimize

  constructor: ->
    almondInPath  = path.join __dirname, "assets", "almond.js"
    @almondText = fs.readFileSync almondInPath, "utf8"

  execute: (runConfig, callback) =>
    if (runConfig.name? and runConfig.name isnt 'almond') or runConfig.name is null
      logger.info "r.js name changed from default of 'almond', so not using almond.js"
    else
      almondOutPath = path.join runConfig.baseUrl, "almond.js"
      unless fs.existsSync(almondOutPath)
        fs.writeFileSync almondOutPath, @almondText, 'utf8'

    @_executeOptimize runConfig, =>
      logger.info "Requirejs optimization complete."
      callback()

  _executeOptimize: (runConfig, callback) =>
    logger.info "Beginning r.js optimization to result in [[ #{runConfig.out} ]]"
    logger.debug "Config for r.js run:\n#{JSON.stringify(runConfig, null, 2)}"
    try
      requirejs.optimize runConfig, (buildResponse) =>
        reportLines = buildResponse.split("\n")
        for reportLine, i in reportLines
          if reportLine.indexOf('---') is 0
            runConfig.filesUsed = reportLines.splice(i + 1, reportLines.length - (i + 2))
            break

        logger.success "The compiled file [[ #{runConfig.out} ]] is ready for use.", true
        callback()
    catch err
      logger.error "Error occured inside r.js optimizer, error is as follows... #{err}"
      callback()

exports.execute = new Optimize().execute