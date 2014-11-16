require "erbish/version"
require "erb"
require "shellwords"

class Erbish
  SEPARATOR = "\0\0".b
  JOINT = "\xff\xff".b
  DEBUG_TYPE_SIZE = 14

  class << self
    def run(*argv)
      while case argv.first
        when /^-d/
          debug = true
        when /^-p/
          noexec = true
        end
        argv.shift
      end
      erbish = Erbish.new(debug, noexec)
      if argv.empty?
        while l = STDIN.gets
          erbish.run(*Shellwords.split(l))
        end
      else
        erbish.run(*argv)
      end
    end
  end

  def initialize(debug = false, noexec = false)
    @binding = binding
    @debug = !!debug
    @noexec = noexec
  end

  def parse(*argv)
    return if argv.empty?
    argv = argv.map(&:b)
    debug_p "raw argv", *argv
    argv.each do |arg|
      if /^([%\-])?%(.*?)(-)?\z/m =~ arg
        joint = $3
        case $1
        when "%"
          arg[0, 1] = ""
        when "-"
          arg.replace "#{JOINT}<%#{$2}%>"
        when nil
          arg.replace "<#{arg}%>"
          joint = true
        end
        arg << JOINT if $3
      end
    end
    debug_p "parsed argv", *argv
    argbuf = ERB.new(argv.join(SEPARATOR).b, nil, "-").result(@binding)
    [/#{JOINT}#{SEPARATOR}#{JOINT}/,                            # %arg1- -%arg2
     /(?:\A|#{SEPARATOR})#{JOINT}|#{JOINT}(?:#{SEPARATOR}|\z)/  # erbish 
    ].each_with_index do |pat, i|
      argbuf.gsub!(pat, "")
    end
    argbuf << SEPARATOR << JOINT
    argv = argbuf.split(SEPARATOR)
    argv.pop
    debug_p "ERBed argv", *argv
    new_line = true
    args = []
    argv.each do |arg|
      args.push [] if new_line
      new_line = arg.sub!(/;\z/, "") && arg !~ /;\z/
      next if new_line && arg.empty?
      args.last.push arg
    end
    debug_p("result args", *args)
    args
  end

  def run(*argv)
    if @noexec
      line = parse(*argv).map do |argv|
        argv.join(" ")
      end.join("\n")
      debug_p("result", *line)
      puts line
    else
      parse(*argv).each do |argv|
        debug_p "system", *argv
        system(*argv)
      end
    end
  end

  private

  def debug_p(type, *objs)
    STDERR.printf "%-#{DEBUG_TYPE_SIZE}s: %s\n", type, objs.map(&:inspect).join(", ") if @debug
  end
end
