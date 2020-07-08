require! {
    \prelude-ls : { each }
    \./handlers.ls
    \moment
}

#2020-07-08 19:50:05 UTC http.worker440 DEBUG txqueue  Re-computing pending set for block: 1675476
#2020-07-08 19:49:57 UTC Periodic Snapshot INFO snapshot::service  Finished taking snapshot at #1675000, in 1893s

regexp = /([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) UTC ([a-zA-Z ]+ \#[0-9]+|http\.worker[0-9]+|Periodic Snapshot) ([A-Za-z\_]+) (.+)/


module.exports = (ws, db)-> (line)->
    result = line.match regexp
    cb = ->
    #uncomment to debug ignored messages
    #console.log \cannot-process, line if not result?
    return cb \cannot-process, line if not result?
    [ _, date, time, role, type, message ] = result
    message = { date, time, role, type, message }
    handlers |> each (-> it db, ws, message)
    db.put "#{type}/last-update" , moment.utc!, cb