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

def two_sum(_numbers, _target)
  _numbers.each_with_index do |number, index|
    _numbers.each_with_index do |number2, index2|
      return [index2, index] if number + number2 == _target && index != index2
    end
  end
end

examples = [
  [[4, 2, 5, 11, -1], 9, [2, 0]],
  [[7, 3, 3, 4, 6], 6, [2, 1]],
  [[13, 2, 1, 6, -4], 9, [4, 0]]
]

# examples = [
#   [[13, 2, 1, 6, -4], 9, [4, 0]]
# ]

examples.each do |(numbers, target, expected)|
  result = two_sum(numbers, target)

  unless result == expected || result.reverse == expected
    raise "Given #{numbers}, expected #{expected} but got #{result}"
  end

  puts "Expected #{expected} for #{numbers} and #{target}, got #{result}"
end
