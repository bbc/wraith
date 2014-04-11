require 'stringio'

stdout = StringIO.new
$stdout = stdout

puts 'foo'

$stdout = STDOUT

puts stdout.string.match /foo/
