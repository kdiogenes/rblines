# Rblines

Rblines is a Ruby clone of the [Redlines](https://github.com/houfu/redlines) Python package. It produces a Markdown text showing the differences between two strings/text. The changes are represented with strike-throughs and underlines, which looks similar to Microsoft Word's track changes. This method of showing changes is more familiar to lawyers and is more compact for long series of characters.

## Example

Given an original string:

    The quick brown fox jumps over the lazy dog.

And the string to be tested with:

    The quick brown fox walks past the lazy dog.

The library gives a result of:

    The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog.

Which is rendered like this:

The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rblines

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rblines

## Usage

The library contains one class: `Rblines::Redlines`, which is used to compare text.

```ruby
test = Rblines::Redlines.new(
    "The quick brown fox jumps over the lazy dog.",
    "The quick brown fox walks past the lazy dog.",
    markdown_style: "none"
)
test.output_markdown == "The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog."
# => True
```

Alternatively, you can create Redline with the text to be tested, and compare several times to see the results.

```ruby
test = Rblines::Redlines.new("The quick brown fox jumps over the lazy dog.", markdown_style: "none")
test.compare("The quick brown fox walks past the lazy dog.") == "The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog."
# => True

test.compare("The quick brown fox jumps over the dog.") == "The quick brown fox jumps over the <del>lazy </del>dog."
# => True
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Know Issues

The original [Redlines](https://github.com/houfu/redlines) uses the `SequenceMatcher` from [difflib](https://github.com/python/cpython/blob/main/Lib/difflib.py). This handles the diff a bit different from the gem [diff-lcs](https://github.com/halostatue/diff-lcs) that we are using in this project. So in the spec `handles different number of paragraphs correctly` we changed the expected output a bit:

```ruby
# changed the expected output from:
expected_md = "Happy Saturday, \n\nThank you for reaching <del>out, have </del><ins>out. Have </ins>a good <del>weekend \n\nBest, ¶ Sophia</del><ins>weekend. \n\nSophia.</ins>"
# to:
expected_md = "Happy Saturday, \n\nThank you for reaching <del>out, have </del><ins>out. Have </ins>a good <del>weekend </del><ins>weekend. </ins>\n\n<del>Best, </del><ins>Sophia.</ins><del>¶ Sophia</del>"
```

We think that the Redlines output is better, but until we find a better way to handle this, we will keep the current output, that is also not that bad.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kdiogenes/rblines.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
