require! {
    \./db.ls
    \prelude-ls : { each }
}

keepers =
    * require \./handlers/last-activity.ls
    * require \./handlers/config.ls
    * require \./handlers/height.ls
    * require \./handlers/reorg.ls
    * require \./handlers/trace.ls
    ...

regexp = /([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) UTC ([a-zA-Z ]+ \#[0-9]+|http\.worker450) ([A-Z]+) (.+)/

module.exports = (ws)-> (line)->
    result = line.match regexp
    cb = ->
    return cb \cannot-process, line if not result?
    [ _, date, time, role, type, message ] = result
    message = { date, time, role, type, message }
    keepers |> each (-> it db, ws, message)