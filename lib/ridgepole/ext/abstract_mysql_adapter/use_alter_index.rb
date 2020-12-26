# frozen_string_literal: true

require 'active_record/connection_adapters/abstract_mysql_adapter'

module Ridgepole
  module Ext
    module AbstractMysqlAdapter
      module UseAlterIndex
        if ActiveRecord.gem_version >= Gem::Version.new('6.1.0')
          def add_index(table_name, column_name, options = {})
            index, _algorithm, if_not_exists = add_index_options(table_name, column_name, **options)

            # cannot specify index_algorithm
            create_index = ActiveRecord::ConnectionAdapters::CreateIndexDefinition.new(index, nil, if_not_exists)

            # Convert `CREATE INDEX` to `ALTER TABLE`
            sql = schema_creation.accept(create_index)
            sql.sub!(/^CREATE/, "ADD")
            sql.remove!(" ON #{quote_table_name(index.table)}")
            execute "ALTER TABLE #{quote_table_name(index.table)} #{sql}"
          end

          def remove_index(table_name, options)
            index_name = index_name_for_remove(table_name, options)
            execute "ALTER TABLE #{quote_table_name(table_name)} DROP INDEX #{quote_column_name(index_name)}"
          end

          def remove_index(table_name, column_name = nil, **options)
            index_name = index_name_for_remove(table_name, column_name, options)

            execute "ALTER TABLE #{quote_table_name(table_name)} DROP INDEX #{quote_column_name(index_name)}"
          end
        else
          def add_index(table_name, column_name, options = {})
            index_name, index_type, index_columns, index_options, _index_algorithm, index_using = add_index_options(table_name, column_name, **options)

            # cannot specify index_algorithm
            execute "ALTER TABLE #{quote_table_name(table_name)} ADD #{index_type} INDEX #{quote_column_name(index_name)} #{index_using} (#{index_columns})#{index_options}"
          end

          def remove_index(table_name, options)
            index_name = index_name_for_remove(table_name, options)
            execute "ALTER TABLE #{quote_table_name(table_name)} DROP INDEX #{quote_column_name(index_name)}"
          end
        end
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      prepend Ridgepole::Ext::AbstractMysqlAdapter::UseAlterIndex
    end
  end
end
