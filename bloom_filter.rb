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
    mask = make_mask(key) # => 0s and 1s
    # indexes = indexes_of_ones(mask) # => return the indexes of just the 1s
    mask.each { |index|
      @bitmap[index] = 1 # assign ones to the overall Filter at the specific indexes
    }
  end

  def new?(key)
    mask = make_mask(key)

    # indexes = indexes_of_ones(mask)
    if key == "Aston"
      #   puts mask.inspect
      puts mask.map { |idx| @bitmap[idx] }.inspect
    end
    if mask.map { |idx| @bitmap[idx] }.include?(0)
      true
    else
      false
    end
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
    @__mask = Array.new(@num_hashes, 0)
    0.upto(@num_hashes.to_i - 1) do |i|
      item = "#{key}#{i}"
      indexhash = (FNV.new.fnv1_32(item)) % @size
      @__mask.push(indexhash)
      #   @__mask[indexhash] = 1
    end
    return @__mask
  end
end

def main(list, string)
  mem = GetProcessMem.new
  bf = BloomFilter.new(1000000, 5)
  list[0..10000].each.with_index { |word, index|
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
