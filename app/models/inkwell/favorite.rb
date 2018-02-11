# frozen_string_literal: true

module Inkwell
  class Favorite < ApplicationRecord
    include Inkwell::CacheCountersCommon

    belongs_to :favorite_subject, polymorphic: true
    belongs_to :favorite_object, polymorphic: true

    after_create :inkwell_after_create
    after_destroy :inkwell_after_destroy

    validates :favorite_subject, presence: true
    validates :favorite_object, presence: true

    private

      def inkwell_after_create
        process_object_counters(favorite_object, favorite_count: 1)
        process_subject_counters(favorite_subject, favorite_count: 1)
      end

      def inkwell_after_destroy
        process_object_counters(favorite_object, favorite_count: -1)
        process_subject_counters(favorite_subject, favorite_count: -1)
      end
  end
end
