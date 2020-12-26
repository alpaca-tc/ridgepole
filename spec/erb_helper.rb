# frozen_string_literal: true

include ERBh

ERBh.define_method(:i) do |obj|
  if obj.nil? || (obj.respond_to?(:empty?) && obj.empty?)
    @_erbout.sub!(/,\s*\z/, '')
    ''
  elsif obj.is_a?(Hash)
    obj.modern_inspect_without_brace(space_inside_hash: true)
  else
    obj
  end
end

ERBh.define_method(:cond) do |conds, m, e = nil|
  if condition(*Array(conds))
    m
  else
    e || (begin
      m.class.new
    rescue StandardError
      nil
    end)
  end
end

require 'pry'

ERBh.define_method(:table_options) do |*args, **original_options|
  options = original_options.deep_dup

  split_id_options = ->(options) {
    return unless options[:id].is_a?(Hash)

    id_options = options.delete(:id)

    options[:id] = id_options.fetch(:type)
    options[:unsigned] = id_options[:unsigned] if id_options.key?(:unsigned)
    options[:limit] = id_options[:limit] if id_options.key?(:limit)
  }

  merge_table_options = ->(options) {
    charset = options.delete(:charset)
    collation = options.delete(:collation)

    table_options = "#{options[:options]}".dup
    table_options << " DEFAULT CHARSET=#{charset}" if charset
    table_options << " COLLATE=#{collation}" if collation

    options[:options] = table_options
  }

  if condition('>= 6.1')
    # 'ENGINE=InnoDB' is a default ENGINE
    # https://github.com/rails/rails/pull/39365/files#diff-868f1dccfcbed26a288bf9f3fd8a39c863a4413ab0075e12b6805d9798f556d1R441
    options.delete(:options) if options[:options] == 'ENGINE=InnoDB'
  elsif condition('6.0')
    split_id_options.call(options)
    merge_table_options.call(options)
  elsif condition('5.2')
    split_id_options.call(options)
    merge_table_options.call(options)
  elsif condition('5.1')
    split_id_options.call(options)
    merge_table_options.call(options)
  elsif condition('5.0')
    split_id_options.call(options)
    merge_table_options.call(options)
    options.delete(:default)
    options.delete(:id) if (options[:id] == :integer && original_options[:id] != :integer) || (options[:id] == :bigint && original_options[:id] != :bigint)
  end

  options.slice(:primary_key, :id, :unsigned, :limit, :default, :charset, :collation, :force, :options)
end
