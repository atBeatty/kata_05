require "fnv"
require "get_process_mem"
file = File.open("wordlist.txt")
results = file.readlines().map { |line|
  line.encode!("UTF-16", :undef => :replace, :invalid => :replace, :replace => "")
  line.encode!("UTF-8")
}

class BloomFilter
  attr_accessor :bitmap

  def initialize(max_entries, num_hashes)
    @num_hashes = num_hashes
    @size = max_entries.to_i
    @bitmap = Array.new(@size, 0)
  end

  def insert(key) # INSERT A HASHCODE COMBO INTO THE BITMAP ARRAY
    mask = make_mask(key) # => array of num_hashes length, filled with "index" numbers
    mask.each { |index|
      @bitmap[index] = 1 # => assign ones to the overall Filter at the specific indexes
    }
  end

  def new?(key)
    mask = make_mask(key)
    # if key == "Aston"
    #   puts mask.inspect
    #   puts mask.map { |idx| @bitmap[idx] }.inspect
    # end
    mask.map { |idx| @bitmap[idx] }.include?(0) # => if one zero occurs, we know it is NEW, else not
  end

  #   def indexes_of_ones(bitmap)
  #     # FIND THE INDEXES IN bitmap ARRAY AND RETURN THE ONES
  #     indexes = []
  #     bitmap.each.with_index { |bit, index|
  #       if bit == 1
  #         indexes.push(index)
  #       end
  #     }
  #     indexes
  #   end

  def make_mask(key)
    @__mask = Array.new(@num_hashes, 0) # => make a mask array with as many elements as they are hash functions
    0.upto(@num_hashes.to_i - 1) do |i|
      item = "#{key}#{i}" # => IM NOT SURE IF THIS IS WHAT A SEED IS? only way to introduce measured variability amongst the number of hash functions being iterated
      indexhash = (FNV.new.fnv1_32(item)) % @size # => I thought this was so cool, easy way to make huge numbers usable
      @__mask.push(indexhash) # => push the index to we know what combo of 1s equates to the key/string/word
      #   @__mask[indexhash] = 1
    end
    return @__mask
  end
end

def main(list, string)
  mem = GetProcessMem.new
  bf = BloomFilter.new(1000000, 5)
  list[0..10000].each.with_index { |word, index| # => ONLY using with the first 10000 words, before testing check .txt file to know what the last word is in order to genuinely test validity of spell checker
    if bf.new?(word.strip)
      bf.insert(word.strip)
    end
  }
  if bf.new?(string)
    puts "The word ((#{string})) is not in the dictionary"
  else
    puts "The word ((#{string})) is spelled correctly"
  end
  puts mem.inspect
end

main(results, "pxr") #=> false positive
main(results, "Asyut") #=> "The word ((Asyut)) is spelled correctly"
main(results, "Aston") #=> "The word ((Aston)) is spelled correctly"
main(results, "bylor") #=> false
