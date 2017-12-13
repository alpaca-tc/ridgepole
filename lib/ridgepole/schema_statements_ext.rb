require 'active_record/connection_adapters/abstract/schema_statements'

module Ridgepole
  module SchemaStatementsExt
    def index_name_exists?(table_name, column_name, default = nil)
      if Ridgepole::ExecuteExpander.noop
        caller_methods = caller.map {|i| i =~ /:\d+:in `(.+)'/ ? $1 : '' }
        if caller_methods.any? {|i| i =~ /\Aremove_index/ }
          return true
        elsif caller_methods.any? {|i| i =~ /\Aadd_index/ }
          return false
        end
      end

      if ActiveRecord.gem_version >= Gem::Version.new('5.1.0')
        super(table_name, column_name)
      else
        super
      end
    end

    def rename_table_indexes(table_name, new_name)
      # Nothing to do
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      prepend Ridgepole::SchemaStatementsExt
    end
  end
end
