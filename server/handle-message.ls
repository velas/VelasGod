require! {
    \./db.ls
    \prelude-ls : { each }
}

keepers =
    * require \./handlers/last-activity.ls
    * require \./handlers/config.ls
    * require \./handlers/trace.ls
    ...

regexp = /([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) UTC (IO Worker|Verifier|Monitor) \#[0-9] (TRACE|DEBUG|INFO) (.+)/

module.exports = (ws)-> (line)->
    result = line.match regexp
    return console.log \cannot-process, line if not result?
    [ _, date, time, role, type, message ] = result
    message = { date, time, role, type, message }
    keepers |> each (-> it db, ws, message)