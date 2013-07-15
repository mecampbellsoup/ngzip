require_relative "../../test_helper"
require 'uri'

describe Ngzip do

  it 'must support the static method :build' do
    Ngzip.respond_to?(:build).must_equal true
  end  

end

describe Ngzip::Builder do
  
  let(:builder) {Ngzip::Builder.new()}
  let(:lorem) {File.expand_path('../../../data/a/lorem.txt', __FILE__)}
  let(:ipsum) {File.expand_path('../../../data/a/ipsum.txt', __FILE__)}
  let(:whitespaced) {File.expand_path('../../../data/a/A filename with whitespace.txt', __FILE__)}
  let(:cargo) {File.expand_path('../../../data/b/Cargo.png', __FILE__)}
  let(:sit) {File.expand_path('../../../data/sit.txt', __FILE__)}
  let(:a) {File.expand_path('../../../data/a', __FILE__)}
  
  it 'must be defined' do
    Ngzip::Builder.wont_be_nil
  end 
  
  it 'must be a class we can call :new on' do
    Ngzip::Builder.new().wont_be_nil
  end
  
  it 'must respond to :build' do
    builder.respond_to?(:build).must_equal true
  end
  
  describe "with CRC-32 checksums disabled" do
    let(:options) { {:crc => false}}
    
    it 'must return a correct list for one file' do
      expected = "- 446 #{lorem} lorem.txt"
      builder.build(lorem, options).must_equal expected      
    end          
  end
  
  describe "with CRC-32 checksums enabled" do
    let(:options) { {:crc => true}}
    
    it 'must return a correct list for one file with a checksum' do
      expected = "8f92322f 446 #{lorem} lorem.txt"
      builder.build(lorem, options).must_equal expected
    end
    
    it 'must return a correct list for one binary file with a checksum' do
      expected = "b2f4655b 11550 #{cargo} Cargo.png"
      builder.build(cargo, options).must_equal expected
    end
    
    it 'must escape the path name' do
      expected = "8f92322f 446 #{URI.escape(whitespaced)} A filename with whitespace.txt"
      builder.build(whitespaced, options).must_equal expected
    end
    
    it 'must return a correct list for all files in a directory' do
      expected = "8f92322f 446 #{URI.escape(whitespaced)} A filename with whitespace.txt"
      expected << "\n8f92322f 446 #{ipsum} ipsum.txt"
      expected << "\n8f92322f 446 #{lorem} lorem.txt"
      builder.build(a,options).must_equal expected
    end
    
    it 'must allow to mix files and directories' do
      expected = "8f92322f 446 #{URI.escape(whitespaced)} a/A filename with whitespace.txt"
      expected << "\n8f92322f 446 #{ipsum} a/ipsum.txt"
      expected << "\n8f92322f 446 #{lorem} a/lorem.txt"
      expected << "\nf7c0867d 1342 #{sit} sit.txt"
      builder.build([a,sit], options).must_equal expected      
    end
    
    it 'must preserve directory names' do
      expected = [
        "8f92322f 446 #{lorem} a/lorem.txt",
        "8f92322f 446 #{ipsum} a/ipsum.txt",
        "b2f4655b 11550 #{cargo} b/Cargo.png"
        ].join("\n")
      builder.build([lorem,ipsum,cargo], options).must_equal expected
    end
    
    it 'must honor the CRC cache' do
      invalid_but_cached = "781aaabcc124"
      expected = "#{invalid_but_cached} 446 #{lorem} lorem.txt"
      builder.build(lorem, options.merge(:crc_cache => {lorem => invalid_but_cached})).must_equal expected
    end
      
  end
  
end