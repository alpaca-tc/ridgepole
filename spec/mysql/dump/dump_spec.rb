# frozen_string_literal: true

describe 'Ridgepole::Client#dump' do
  context 'when there is a tables' do
    before { restore_tables }
    subject { client }

    it {
      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "clubs", <%= i table_options(id: { type: :integer , unsigned: true }, charset: 'utf8', force: :cascade) %> do |t|
          t.string "name", default: "", null: false
          t.index ["name"], name: "idx_name", unique: true, <%= i cond(5.0, using: :btree) %>
        end

        create_table "departments", <%= i table_options(primary_key: "dept_no", id: { type: :string, limit: 4 }, charset: 'utf8', force: :cascade) %> do |t|
          t.string "dept_name", limit: 40, null: false
          t.index ["dept_name"], name: "dept_name", unique: true, <%= i cond(5.0, using: :btree) %>
        end

        create_table "dept_emp", <%= i table_options(primary_key: ["emp_no", "dept_no"], charset: 'utf8', force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.string  "dept_no", limit: 4, null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
          t.index ["dept_no"], name: "dept_no", <%= i cond(5.0, using: :btree) %>
          t.index ["emp_no"], name: "emp_no", <%= i cond(5.0, using: :btree) %>
        end

        create_table "dept_manager", <%= i table_options(primary_key: ["emp_no", "dept_no"], charset: 'utf8', force: :cascade) %> do |t|
          t.string  "dept_no", limit: 4, null: false
          t.integer "emp_no", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
          t.index ["dept_no"], name: "dept_no", <%= i cond(5.0, using: :btree) %>
          t.index ["emp_no"], name: "emp_no", <%= i cond(5.0, using: :btree) %>
        end

        create_table "employee_clubs", <%= i table_options(id: { type: :integer, unsigned: true }, charset: 'utf8', force: :cascade) %> do |t|
          t.integer "emp_no", null: false, unsigned: true
          t.integer "club_id", null: false, unsigned: true
          t.index ["emp_no", "club_id"], name: "idx_emp_no_club_id", <%= i cond(5.0, using: :btree) %>
        end

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

        create_table "titles", <%= i table_options(primary_key: ["emp_no", "title", "from_date"], charset: 'utf8', force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.string  "title", limit: 50, null: false
          t.date    "from_date", null: false
          t.date    "to_date"
          t.index ["emp_no"], name: "emp_no", <%= i cond(5.0, using: :btree) %>
        end
      ERB
    }
  end
end
