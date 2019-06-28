# frozen_string_literal: true

require "test_helper"
require "redi_search/index"

module RediSearch
  class IndexTest < ActiveSupport::TestCase
    setup do
      @index = Index.new("users_test", first: :text, last: :text)
      @index.drop
      @index.create
    end

    teardown do
      @index.drop
    end

    test "#add" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record.redi_search_document)
      assert_equal 1, @index.info["num_docs"].to_i
    end

    test "#document_count" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record.redi_search_document)
      assert_equal @index.info["num_docs"].to_i, @index.document_count
    end

    test "create fails if the index already exists" do
      dup_index = Index.new("users_test", first: :text, last: :text)

      assert_not dup_index.create
    end

    test "info returns nothing if the index doesnt exist" do
      rando_idx = Index.new("rando_idx", first: :text, last: :text)

      assert_nil rando_idx.info
    end

    test "#fields" do
      assert_equal %w(first last), @index.fields
    end

    test "#reindex" do
      assert_equal 0, @index.info["num_docs"].to_i
      assert @index.reindex(User.all.map(&:redi_search_document))
      assert_equal User.count, @index.info["num_docs"].to_i
    end

    test "#search" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record.redi_search_document)
      assert_equal 1, @index.search(record.first).count

      record_jr = record.dup
      record_jr.last = record_jr.last + " jr"
      record_jr.save
      assert @index.add(record_jr.redi_search_document)
      assert_equal 2, @index.search(record.first).count
    end

    test "Results#size is aliased to count" do
      record = User.create(
        first: Faker::Name.first_name, last: Faker::Name.last_name
      )
      assert @index.add(record.redi_search_document)
      assert_equal(
        @index.search(record.first).count, @index.search(record.first).size
      )
    end

    test "#exists?" do
      assert @index.exist?
      assert @index.drop
      assert_not @index.exist?
    end
  end
end
