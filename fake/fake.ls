require! {
    \prelude-ls : { sort-by, head, split }
    fs : { read-file-sync }
}

fake = read-file-sync \./fake.txt , \utf8

fake-str =
    fake |> split "\n"

produce-line = ->
    <- set-timeout _, 1000
    command = 
        fake-str 
            |> sort-by -> Math.random!
            |> head
    console.error command
    produce-line!
    
produce-line!
        