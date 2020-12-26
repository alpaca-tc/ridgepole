# frozen_string_literal: true

describe 'Ridgepole::Client#diff -> migrate' do
  context 'when with tables option (same)' do
    let(:current_schema) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(id: false, charset: "utf8", force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        add_index "salaries", ["salary"], name: "emp_no", using: :btree
      ERB
    end

    let(:dsl) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(id: false, charset: "utf8", force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        add_index "salaries", ["emp_no"], name: "emp_no", using: :btree
      ERB
    end

    let(:expected_dsl) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end
      ERB
    end

    before { subject.diff(current_schema).migrate }
    subject { client(tables: ['employees']) }

    it {
      delta = subject.diff(dsl)
      expect(delta.differ?).to be_falsey
      expect(subject.dump).to match_ruby expected_dsl
      delta.migrate
      expect(subject.dump).to match_ruby expected_dsl
    }
  end

  context 'when with tables option (differ)' do
    let(:current_schema) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(id: false, charset: "utf8", force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        add_index "salaries", ["salary"], name: "emp_no", using: :btree
      ERB
    end

    let(:dsl) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 15, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end

        create_table "salaries", <%= i table_options(id: false, charset: "utf8", force: :cascade) %> do |t|
          t.integer "emp_no", null: false
          t.integer "salary", null: false
          t.date    "from_date", null: false
          t.date    "to_date", null: false
        end

        add_index "salaries", ["emp_no"], name: "emp_no", using: :btree
      ERB
    end

    let(:before_dsl) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 14, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end
      ERB
    end

    let(:after_dsl) do
      erbh(<<-ERB)
        create_table "employees", <%= i table_options(primary_key: "emp_no", charset: "utf8", force: :cascade) %> do |t|
          t.date   "birth_date", null: false
          t.string "first_name", limit: 15, null: false
          t.string "last_name", limit: 16, null: false
          t.string "gender", limit: 1, null: false
          t.date   "hire_date", null: false
        end
      ERB
    end

    before { subject.diff(current_schema).migrate }
    subject { client(tables: ['employees']) }

    it {
      delta = subject.diff(dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump).to match_fuzzy before_dsl
      delta.migrate
      expect(subject.dump).to match_fuzzy after_dsl
    }
  end
end
