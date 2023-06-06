# frozen_string_literal: true

require "strscan"
require "diff/lcs"

# This regular expression matches a group of characters that can include any character except for parentheses
# and whitespace characters (which include spaces, tabs, and line breaks) or any character
# that is a parenthesis or punctuation mark (.?!-).
# The group can also include any whitespace characters that follow these characters.
# Breaking it down further:
# - ( and ) indicate a capturing group
# - (?: ) is a non-capturing group, meaning it matches the pattern but doesn't capture the matched text
# - [^()\s]+ matches one or more characters that are not parentheses or whitespace characters
# - | indicates an alternative pattern
# - [().?!-] matches any character that is a parenthesis or punctuation mark (.?!-)
# - \s* matches zero or more whitespace characters (spaces, tabs, or line breaks) that follow the previous pattern.
TOKENIZER = /((?:[^()\s]+|[().?!-])\s*)/

# This pattern matches one or more newline characters `\n`, and any spaces between them.
# It is used to split the text into paragraphs.
# - (?:\n *) is a non-capturing group that must start with a \n and be followed by zero or more spaces.
# - ((?:\n *)+) is the previous non-capturing group repeated one or more times.
PARAGRAPH_PATTERN = /((?:\n *)+)/

SPACE_PATTERN = /(\s+)/

# Tokenizes the text based on the TOKENIZER pattern.
#
# @param text [String] the text to be tokenized
# @return [Array<String>] an array of tokenized words
def tokenize_text(text)
  text.scan(TOKENIZER).flatten
end

# Splits a string into a list of paragraphs. One or more `\n` splits the paragraphs.
# For example, if the text is "Hello\nWorld\nThis is a test", the result will be:
# ['Hello', 'World', 'This is a test']
#
# @param text [String] the text to split
# @return [Array<String>] a list of paragraphs
def split_paragraphs(text)
  text.split(PARAGRAPH_PATTERN)
    .map(&:strip)
    .reject(&:empty?)
end

# Split paragraphs and concatenate them. Then add a character '¶' between paragraphs.
# For example, if the text is "Hello\nWorld\nThis is a test", the result will be:
# "Hello¶World¶This is a test"
#
# @param text [String] the text to split
# @return [String] a string with paragraphs separated by '¶'
def concatenate_paragraphs_and_add_chr182(text)
  split_paragraphs(text).join(" ¶ ")
end

module Rblines
  # The Redlines class is used to compare two texts and generate a markdown output highlighting the differences between
  # them.
  #
  # @example
  #   redlines = Rblines::Redlines.new("source text", "test text")
  #   result = redlines.output_markdown
  class Redlines
    MD_STYLES = {
      "none" => {"ins" => %w[ins ins], "del" => %w[del del]},
      "red" => {
        "ins" => ['span style="color:red;font-weight:700;"', "span"],
        "del" => ['span style="color:red;font-weight:700;text-decoration:line-through;"', "span"]
      }
    }.freeze

    attr_accessor :options
    attr_reader :source, :test

    def source=(value)
      @source = value
      @seq1 = tokenize_text(concatenate_paragraphs_and_add_chr182(value))
    end

    def test=(value)
      @test = value
      @seq2 = tokenize_text(concatenate_paragraphs_and_add_chr182(value))
    end

    def initialize(source, test = nil, **options)
      self.source = source
      self.options = options
      self.test = test if test
    end

    def opcodes
      raise "No test string was provided when the function was called, or during initialisation." if @seq2.nil?

      Diff::LCS.sdiff(@seq1, @seq2)
    end

    def output_markdown
      result = []
      style = MD_STYLES[options[:markdown_style] || "red"]
      grouped_opcodes = opcodes.chunk_while { |a, b| a.action == b.action }.to_a

      grouped_opcodes.each do |group|
        group_action = group[0].action
        case group_action
        when "="
          handle_equal_action(result, group)
        when "+"
          handle_add_action(result, group, style)
        when "-"
          handle_delete_action(result, group, style)
        when "!"
          handle_replace_action(result, group, style)
        end
      end

      result.join
    end

    def handle_equal_action(result, group)
      result.push(group.map(&:old_element).join.gsub("¶ ", "\n\n"))
    end

    def handle_add_action(result, group, md_styles)
      temp_str = group.map(&:new_element).join.split("¶ ")
      temp_str.each { |split| result.push("<#{md_styles["ins"][0]}>#{split}</#{md_styles["ins"][1]}>", "\n\n") }
      result.pop if temp_str.length.positive?
    end

    def handle_delete_action(result, group, md_styles)
      result.push("<#{md_styles["del"][0]}>#{group.map(&:old_element).join}</#{md_styles["del"][1]}>")
    end

    def handle_replace_action(result, group, md_styles)
      result.push("<#{md_styles["del"][0]}>#{group.map(&:old_element).join}</#{md_styles["del"][1]}>")
      temp_str = group.map(&:new_element).join.split("¶ ")
      temp_str.each { |split| result.push("<#{md_styles["ins"][0]}>#{split}</#{md_styles["ins"][1]}>", "\n\n") }
      result.pop if temp_str.length.positive?
    end

    def compare(test = nil, output = "markdown", options = {})
      self.test = test if test
      raise "No test string was provided when the function was called, or during initialisation." if self.test.nil?

      self.options.merge!(options)

      return unless output == "markdown"

      output_markdown
    end
  end
end
