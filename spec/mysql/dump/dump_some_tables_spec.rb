# frozen_string_literal: true

describe 'Ridgepole::Client#dump' do
  context 'when there is a tables (dump some tables)' do
    before { restore_tables }
    subject { client(tables: %w[employees salaries]) }

    it {
      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", id: :integer, default: nil, charset: 'utf8', force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          <%- if condition('< 6.0.0.beta2') -%>
          t.string "gender", limit: 1, null: false
          <%- else -%>
          t.column "gender", "enum('M','F')", null: false
          <%- end -%>
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(primary_key: ["emp_no", "from_date"], charset: 'utf8', force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
          t.index ["emp_no"], name: "emp_no", <%= i cond(5.0, using: :btree) %>
        end
      ERB
    }
  end

  context 'when there is a tables (use ignore table)' do
    before { restore_tables }
    subject do
      client(ignore_tables: [
               /^clubs$/,
               /^departments$/,
               /^dept_emp$/,
               /^dept_manager$/,
               /^employee_clubs$/,
               /^titles$/
             ])
    end

    it {
      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", id: :integer, default: nil, charset: 'utf8') %>, force: :cascade do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          <%- if condition('< 6.0.0.beta2') -%>
          t.string "gender", limit: 1, null: false
          <%- else -%>
          t.column "gender", "enum('M','F')", null: false
          <%- end -%>
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(primary_key: ["emp_no", "from_date"], charset: 'utf8', force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
          t.index ["emp_no"], name: "emp_no", <%= i cond(5.0, using: :btree) %>
        end
      ERB
    }
  end
end
