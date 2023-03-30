# frozen_string_literal: true

class OrganizationDataPolicy < GdprAdmin::ApplicationDataPolicy
  before_process -> { skip_data_policy! }

  def scope
    Organization.all
  end

  def erase(_organization)
    raise 'error'
  end
end
