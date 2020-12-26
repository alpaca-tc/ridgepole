# frozen_string_literal: true

describe 'Ridgepole::Client (use default:lambda)' do
  context 'when create table with default:lambda' do
    subject { client }

    it do
      delta = subject.diff(erbh(<<-ERB))
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB
    end
  end

  context 'when there is no difference' do
    let(:dsl) do
      erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB
    end

    subject { client }

    before do
      subject.diff(dsl).migrate
    end

    it do
      delta = subject.diff(dsl)
      expect(delta.differ?).to be_falsey
    end
  end

  context 'when change column (1)' do
    subject { client }

    before do
      subject.diff(erbh(<<-ERB)).migrate
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB
    end

    it do
      delta = subject.diff(erbh(<<-ERB))
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { '"1970-01-01 00:00:00"' }, null: false
        end
      ERB

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_ruby erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: "1970-01-01 00:00:00", null: false
        end
      ERB
    end
  end

  context 'when change column (2)' do
    subject { client }

    before do
      subject.diff(erbh(<<-ERB)).migrate
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: '1970-01-01 00:00:00', null: false
        end
      ERB
    end

    it do
      delta = subject.diff(erbh(<<-ERB))
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
        end
      ERB
    end
  end

  context 'when add column' do
    subject { client }

    before do
      subject.diff(erbh(<<-ERB)).migrate
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.integer "zoo"
        end
      ERB
    end

    it do
      delta = subject.diff(erbh(<<-ERB))
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
          t.integer "zoo"
        end
      ERB

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
          t.integer "zoo"
        end
      ERB
    end
  end

  context 'when drop column' do
    subject { client }

    before do
      subject.diff(erbh(<<-ERB)).migrate
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.datetime "bar", default: -> { "CURRENT_TIMESTAMP" }, null: false
          t.integer "zoo"
        end
      ERB
    end

    it do
      delta = subject.diff(erbh(<<-ERB))
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.integer "zoo"
        end
      ERB

      expect(delta.differ?).to be_truthy
      delta.migrate

      expect(subject.dump).to match_fuzzy erbh(<<-ERB)
        create_table "foos", <%= i table_options(charset: "utf8", force: :cascade) %> do |t|
          t.integer "zoo"
        end
      ERB
    end
  end
end
