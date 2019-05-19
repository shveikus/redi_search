# frozen_string_literal: true

require "test_helper"
require "redi_search/search/highlight_clause"

module RediSearch
  class Search
    class HighlightClauseTest < ActiveSupport::TestCase
      setup do
        @clause = RediSearch::Search::HighlightClause
      end

      test "returns HIGHLIGHT keyword" do
        assert_equal ["HIGHLIGHT"], @clause.new.clause
      end

      test "tags clause" do
        assert_equal(
          ["HIGHLIGHT", "TAGS", "<b>", "</b>"],
          @clause.new(tags: { open: "<b>", close: "</b>" }).clause
        )
      end

      test "tags with no opening" do
        assert_raise ArgumentError do
          @clause.new(tags: { close: "</b>" }).clause
        end
      end

      test "tags with no closing" do
        assert_raise ArgumentError do
          @clause.new(tags: { open: "<b>" }).clause
        end
      end

      test "fields clause" do
        assert_equal(
          ["HIGHLIGHT", "FIELDS", 1, ["name"]],
          @clause.new(fields: ["name"]).clause
        )
      end

      test "fields is always before tags" do
        assert_equal(
          ["HIGHLIGHT", "FIELDS", 1, ["name"], "TAGS", "<b>", "</b>"],
          @clause.new(
            tags: { open: "<b>", close: "</b>" },
            fields: ["name"]
          ).clause
        )
      end
    end
  end
end
