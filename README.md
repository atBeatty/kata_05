# Implementation

1. Clone repo
1. Navigate terminal to local directory where folder is cloned
1. The gems needed are:
   - "fnv"
   - "get_process_mem" (this is optional, it helped me track some of the memory usage during testing)
1. In the command line, run the following command
   - _ruby run bloom_filter.rb_

# Usage

1. Chamge lines 80-83, the string being passed into this function is what the spell-checker is testing for
1. Experiement with line 66, substitute the arguments for the BloomFilter constructor with difference values to check performance measures

# Issues and Talking Points

1. Strip function was not working consistently, couldn't figure out why
1. Testing was done for up to 10000 items, in this case words from dictionary
1. Didn't need indexes_of_ones method, saved time and memory
1. The individual mask arrays were being initialized with size of @size, changed to making the mask representative of indexes and not 0s and 1s
