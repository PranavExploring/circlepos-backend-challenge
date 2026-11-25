# CirclePOS Backend Developer Challenge

## Part 1: ISBN-13 Check Digit Calculator (Ruby)

Calculates the ISBN-13 check digit from a 12-digit input and returns the complete 13-digit ISBN as a string.

### Requirements
- Ruby 3.x (uses standard library Minitest; no external gems required)

### Usage
```bash
ruby -Ilib -r isbn13_calculator -e 'puts Isbn13Calculator.complete("978014300723")'
# => 9780143007234
```

### Run Tests
```bash
ruby test/isbn13_calculator_test.rb
```
