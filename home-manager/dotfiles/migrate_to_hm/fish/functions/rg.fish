function rg
    /usr/bin/rg --json -C 2 $argv[1] | delta
end

