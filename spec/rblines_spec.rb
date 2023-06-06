# frozen_string_literal: true

require_relative '../lib/rblines/redlines'

RSpec.describe Rblines::Redlines do
  [
    [
      'The quick brown fox jumps over the dog.',
      'The quick brown fox jumps over the lazy dog.',
      'The quick brown fox jumps over the <ins>lazy </ins>dog.'
    ]
  ].each do |test_string1, test_string2, expected_md|
    it 'adds text correctly' do
      test = Rblines::Redlines.new(test_string1, test_string2, markdown_style: 'none')
      expect(test.output_markdown).to eq(expected_md)
    end
  end

  [
    [
      'The quick brown fox jumps over the lazy dog.',
      'The quick brown fox jumps over the dog.',
      'The quick brown fox jumps over the <del>lazy </del>dog.'
    ]
  ].each do |test_string1, test_string2, expected_md|
    it 'deletes text correctly' do
      test = Rblines::Redlines.new(test_string1, test_string2, markdown_style: 'none')
      expect(test.output_markdown).to eq(expected_md)
    end
  end

  [
    [
      'The quick brown fox jumps over the lazy dog.',
      'The quick brown fox walks past the lazy dog.',
      'The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog.'
    ]
  ].each do |test_string1, test_string2, expected_md|
    it 'replaces text correctly' do
      test = Rblines::Redlines.new(test_string1, test_string2, markdown_style: 'none')
      expect(test.output_markdown).to eq(expected_md)
    end
  end

  it 'compares correctly' do
    test_string1 = 'The quick brown fox jumps over the lazy dog.'
    test_string2 = 'The quick brown fox walks past the lazy dog.'
    expected_md = 'The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog.'
    test = Rblines::Redlines.new(test_string1, markdown_style: 'none')

    expect(test.compare(test_string2)).to eq(expected_md)
    expect(test.compare(test_string2)).to eq(expected_md)

    expect(
      test.compare('The quick brown fox jumps over the dog.')
    ).to eq('The quick brown fox jumps over the <del>lazy </del>dog.')

    test = Rblines::Redlines.new(test_string1)
    expect { test.compare }.to raise_error(RuntimeError)
  end

  it 'raises opcodes error' do
    test_string1 = 'The quick brown fox jumps over the lazy dog.'
    test = Rblines::Redlines.new(test_string1)
    expect { test.opcodes }.to raise_error(RuntimeError)
  end

  it 'gets source correctly' do
    test_string1 = 'The quick brown fox jumps over the lazy dog.'
    test = Rblines::Redlines.new(test_string1, markdown_style: 'none')
    expect(test.source).to eq(test_string1)
  end

  it 'handles markdown style correctly' do
    test_string1 = 'The quick brown fox jumps over the lazy dog.'
    test_string2 = 'The quick brown fox walks past the lazy dog.'
    expected_md = 'The quick brown fox <del>jumps over </del><ins>walks past </ins>the lazy dog.'
    test = Rblines::Redlines.new(test_string1, markdown_style: 'none')

    expect(test.compare(test_string2)).to eq(expected_md)

    expected_md = 'The quick brown fox <span style="color:red;font-weight:700;text-decoration:line-through;">jumps over </span><span style="color:red;font-weight:700;">walks past </span>the lazy dog.'
    test = Rblines::Redlines.new(test_string1, markdown_style: 'red')

    expect(test.compare(test_string2)).to eq(expected_md)
  end

  it 'handles paragraphs correctly' do
    test_string1 = "Happy Saturday,\n\nThank you for reaching out, have a good weekend\n\nSophia"
    test_string2 = "Happy Saturday,\n\nThank you for reaching out. Have a good weekend.\n\nSophia."
    expected_md = "Happy Saturday, \n\nThank you for reaching <del>out, have </del><ins>out. Have </ins>a good <del>weekend </del><ins>weekend. </ins>\n\n<del>Sophia</del><ins>Sophia.</ins>"
    test = Rblines::Redlines.new(test_string1, markdown_style: 'none')

    expect(test.compare(test_string2)).to eq(expected_md)
  end

  it 'handles different number of paragraphs correctly' do
    test_string1 = "Happy Saturday,\n\nThank you for reaching out, have a good weekend\n\nBest,\n\nSophia"
    test_string2 = "Happy Saturday,\n\nThank you for reaching out. Have a good weekend.\n\nSophia."
    expected_md = "Happy Saturday, \n\nThank you for reaching <del>out, have </del><ins>out. Have </ins>a good <del>weekend </del><ins>weekend. </ins>\n\n<del>Best, </del><ins>Sophia.</ins><del>¶ Sophia</del>"
    test = Rblines::Redlines.new(test_string1, test_string2, markdown_style: 'none')

    expect(test.output_markdown).to eq(expected_md)
  end
end
