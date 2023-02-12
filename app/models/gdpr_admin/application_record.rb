# frozen_string_literal: true

module GdprAdmin
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
