get-request-id = ->
    get-request-id.counter = get-request-id.counter ? 0
    get-request-id.counter =
        | get-request-id.counter > 100000000 => 1
        | _ => get-request-id.counter + 1
    get-request-id.counter
    
module.exports = get-request-id