# watch bin run
function cwb
    cargo watch -x -c -x "run $argv[1]"
end

# watch example by name
function cwe 
    cargo watch -x -c -x "run -q --example $argv[1]"
end

# install app from cwd
function cwi
    cargo watch -x "install --path ."
end

# watch test

function cwt
    set argc (count $argv) > /dev/null

    if test $argc = 1
        cargo watch -q -c -x "test $argv[1] --" 
    else if test $argc = 2
        cargo watch -q -c -x "test --test $argv[1] $argv[2] --" 
    else
        cargo watch -q -c -x "test --" 
    end
end


function cwtv
    set argc (count $argv) > /dev/null

    if test $argc = 1
        cargo watch -q -c -x "test $argv[1] -- --nocapture" 
    else if test $argc = 2
        cargo watch -q -c -x "test --test $argv[1] $argv[2] -- --nocapture" 
    else
        cargo watch -q -c -x "test -- --nocapture" 
    end
end
