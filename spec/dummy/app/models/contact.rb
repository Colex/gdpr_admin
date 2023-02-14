# frozen_string_literal: true

class Contact < ApplicationRecord
  acts_as_tenant(:organization)
end
