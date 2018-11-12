# Extracts just the definitions from the grammar file
# Returns an array of strings where each string is the lines for
# a given definition (without the braces)

def read_grammar_defs(filename)
  filename = 'grammars/' + filename unless filename.start_with? 'grammars/'
  filename += '.g' unless filename.end_with? '.g'
  contents = open(filename, 'r') {|f| f.read}
  contents.scan(/\{(.+?)\}/m).map do |rule_array|
    rule_array[0]
  end
end

# Takes data as returned by read_grammar_defs and reformats it
# in the form of an array with the first element being the
# non-terminal and the other elements being the productions for
# that non-terminal.
# Remember that a production can be empty (see third example)
# Example:
#   split_definition "\n<start>\nYou <adj> <name> . ;\nMay <curse> . ;\n"
#     returns ["<start>", "You <adj> <name> .", "May <curse> ."]
#   split_definition "\n<start>\nYou <adj> <name> . ;\n;\n"
#     returns ["<start>", "You <adj> <name> .", ""]
def split_definition(raw_def)
  # TODO: your implementation here
  i = 0
  while (i < raw_def.size)
    raw_def[i].gsub! /\s\n/, "\n"
    raw_def[i].gsub! /\n+/, "\n"
    raw_def[i].gsub! /\t/, ''
    i += 1
  end
  x = 0
  newArr = []
  mod_def = []
  until x >= raw_def.size do
    if (raw_def[x][0] == "\n")
      mod_def[x] = raw_def[x][1..-1]
    else
      mod_def[x] = raw_def[x]
    end
    newArr[x] = mod_def[x].split(/\t?\s?;\s?\n?/)
    x += 1
  end

  j = 0
  while (j < newArr.size)
    newArr[j].unshift(newArr[j][0][0..newArr[j][0].index(">")].gsub(/\s*/, ""))
    if newArr[j][0] == "<blank>"
      newArr[j][1] = "";
    else
      newArr[j][1] = newArr[j][1][newArr[j][1].index(">") + 2..-1]
    end
    j += 1
  end

  k = 0
  while (k < newArr.size)
    l = 0
    while (l < newArr[k].size)
      newArr[k][l].gsub! /\n+/, ' '
      l += 1
    end
    k += 1
  end

  return newArr
end


# Takes an array of definitions where the definitions have been
# processed by split_definition and returns a Hash that
# is the grammar where the key values are the non-terminals
# for a rule and the values are arrays of arrays containing
# the productions (each production is a separate sub-array)

# Example:
# to_grammar_hash([["<start>", "The   <object>   <verb>   tonight."], ["<object>", "waves", "big    yellow       flowers", "slugs"], ["<verb>", "sigh <adverb>", "portend like <object>", "die <adverb>"], ["<adverb>", "warily", "grumpily"]])
# returns {"<start>"=>[["The", "<object>", "<verb>", "tonight."]], "<object>"=>[["waves"], ["big", "yellow", "flowers"], ["slugs"]], "<verb>"=>[["sigh", "<adverb>"], ["portend", "like", "<object>"], ["die", "<adverb>"]], "<adverb>"=>[["warily"], ["grumpily"]]}
def to_grammar_hash(split_def_array)
  # TODO: your implementation here
  result_hash = Hash.new
  x = 0
  while x < split_def_array.size do
    y = 1
    temp_array = []
    while y < split_def_array[x].size do
      temp_array[y - 1] = split_def_array[x][y].split(/\s+/)
      y += 1
    end
    result_hash[split_def_array[x][0]] = temp_array
    x += 1
  end

  # puts result_hash.to_s
  return result_hash
end

# Returns true iff s is a non-terminal
# a.k.a. a string where the first character is <
#        and the last character is >
def is_non_terminal?(s)
  # TODO: your implementation here
  # puts s[0] == "<" && s[-1] == ">"
  # puts s[-1]
  return s[0] == "<" && s[-1] == ">"
end

# Given a grammar hash (as returned by to_grammar_hash)
# returns a string that is a randomly generated sentence from
# that grammar
#
# Once the grammar is loaded up, begin with the <start> production and expand it to generate a
# random sentence.
# Note that the algorithm to traverse the data structure and
# return the terminals is extremely recursive.
#
# The grammar will always contain a <start> non-terminal to begin the
# expansion. It will not necessarily be the first definition in the file,
# but it will always be defined eventually. Your code can
# assume that the grammar files are syntactically correct
# (i.e. have a start definition, have the correct  punctuation and format
# as described above, don't have some sort of endless recursive cycle in the
# expansion, etc.). The names of non-terminals should be considered
# case-insensitively, <NOUN> matches <Noun> and <noun>, for example.
def expand(grammar, non_term = "<start>")
  # TODO: your implementation here
  if grammar[non_term]
    gramArr = grammar[non_term]
  elsif grammar[non_term.downcase]
    gramArr = grammar[non_term.downcase]
  elsif grammar[non_term.upcase]
    gramArr = grammar[non_term.upcase]
  elsif grammar[non_term.capitalize]
    gramArr = grammar[non_term.capitalize]
  end

  result_s = ""

  r = rand(gramArr.size)
  i = 0
  while (i < gramArr[r].size)
    if is_non_terminal?(gramArr[r][i])
      result_s += expand(grammar, gramArr[r][i])
    else
      result_s = result_s + gramArr[r][i] + " "
    end
    i += 1
  end
  result_s.gsub! /\s\./, "."
  result_s.gsub! /\s\,/, ","
  result_s.gsub! /\s\!/, "!"
  result_s.gsub! /\s\'/, "'"
  return result_s
end

# Given the name of a grammar file,
# read the grammar file and print a
# random expansion of the grammar
def rsg(filename)
  # TODO: your implementation here
  result = expand(to_grammar_hash(split_definition(read_grammar_defs(filename))))
  puts result
  return result
end

if __FILE__ == $0
  # TODO: your implementation of the following
  # prompt the user for the name of a grammar file
  # rsg that file
  puts "What is the name of the grammar file?"
  filename = gets.chomp

  rsg(filename)
end