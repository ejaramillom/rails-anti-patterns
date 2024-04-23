# Given an array of integers nums and an integer target, return indices of the two numbers
# such that they add up to target.
#
# You may assume that each input would have exactly one solution, and you may not use the
# same element twice.
#
# You can return the answer in any order.
#
# @param {[Number]} numbers List of numbers.
# @param {Number} target The target number.
#
# @return {[Number]}

examples = [
  [[4, 2, 5, 11, -1], 9, [2, 0]],
  [[7, 3, 3, 4, 6], 6, [2, 1]],
  [[13, 2, 1, 6, -4], 9, [4, 0]]
]

# examples = [
#   [[13, 2, 1, 6, -4], 9, [4, 0]]
# ]



def thing(element) 
  string = ""
  element.map do |object| 
    string.concat(" #{object%2}, ")
  end
  
  puts string
end 

array = [1, 2, 3, 4] 

# example:
# in  - [1, 2, 3, 4]
# out - "1, 0, 1, 0"

thing(array)