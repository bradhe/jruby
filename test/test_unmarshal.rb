require 'test/unit'
require 'stringio'

# Test for issue JIRA-2506
# Fails with an EOF error in JRuby 1.1.1, works in MRI 1.8.6
# Author: steen.lehmann@gmail.com

class TestUnmarshal < Test::Unit::TestCase

  def testUnmarshal
    dump = ''
    dump << Marshal.dump("hey")
    dump << Marshal.dump("there")

    result = "none"
    StringIO.open(dump) do |f|
      result = Marshal.load(f)
      assert_equal "hey", result, "first string unmarshalled"      
      result = Marshal.load(f)
    end
    assert_equal "there", result, "second string unmarshalled"
  rescue EOFError
    flunk "Unmarshalling failed with EOF error at " + result + " string."
  end

  def test_fixnum_unbuffered
    # need to read unbuffered value from ChannelStream.
    obj = Array.new(2000, 60803)
    dump = Marshal.dump(obj)
    piper, pipew = IO.pipe
    pipew << dump
    Marshal.load(piper).each do |e|
      assert_equal(60803, e, 'JRUBY-5064')
    end
  end

end
