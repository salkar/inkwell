# frozen_string_literal: true

module Inkwell
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
