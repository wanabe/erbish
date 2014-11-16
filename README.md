# Erbish

ERB In SHell

## Installation

Install:

    $ gem install erbish

## Usage

Execute command with ERB notation.

    $ erbish '<%= "data".succ.succ.succ.succ %>'
    Thu Nov 13 21:09:10 JST 2014

Argument that start '%' is parsed as '<#{arg}%>'

    $ erbish echo 5 + 4 = %=5+4
    5 + 4 = 9

'%'ed argument can be start/end with '-' to join before/after args.

    $ erbish echo B -%=42/10- U
    B4U

    $ erbish ruby -e 'p ARGV' "%3.times do |i|-" %=i -%end- 3
    ["0123"]

';' is interpreted as separator.

    $ erbish "% 3.times do |i|" echo %=i \; %end
    0
    1
    2

option '-d' is for debug.
option '-p' is for just parse args, without execute.

    $ erbish -d echo 1\; echo %=4**5
    raw argv      : ["echo", "1;", "echo", "%=4**5"]
    parsed argv   : ["echo", "1;", "echo", "<%=4**5%>"]
    ERBed argv    : ["echo", "1;", "echo", "1024"]
    result args   : [["echo", "1"], ["echo", "1024"]]
    system        : ["echo", "1"]
    1
    system        : ["echo", "1024"]
    1024

    $ erbish -p echo 1\; echo %=4**5
    echo 1
    echo 1024

Alias and function might be helpful.

    $ cat ~/.bashrc
    ...
    alias es='erbish'
    alias ee='erbish echo'
    e () { while read f; do $f; done < <(erbish -p "$@"); }

    $ ee '%= "".encoding'
    ASCII-8BIT

    $ e '%= "23".tr("0-9", "a-j")' /
    $ pwd
    /

## Contributing

1. Fork it ( https://github.com/[my-github-username]/erbish/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
