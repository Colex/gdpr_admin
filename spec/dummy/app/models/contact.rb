# frozen_string_literal: true

class Contact < ApplicationRecord
  acts_as_tenant(:organization)
  has_paper_trail
end
