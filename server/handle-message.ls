require! {
    \prelude-ls : { each }
    \./handlers.ls
    \moment
}

regexp = /([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}) UTC ([a-zA-Z ]+ \#[0-9]+|http\.worker450) ([A-Za-z\_]+) (.+)/

module.exports = (ws, db)-> (line)->
    result = line.match regexp
    cb = ->
    #console.log \cannot-prelude, line if not result?
    return cb \cannot-process, line if not result?
    [ _, date, time, role, type, message ] = result
    message = { date, time, role, type, message }
    handlers |> each (-> it db, ws, message)
    db.put "#{type}/last-update" , moment.utc!, cb