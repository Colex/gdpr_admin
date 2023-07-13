# frozen_string_literal: true

class ActivityLogDataPolicy < GdprAdmin::ApplicationDataPolicy
  def fields
    [
      { field: 'sign_in_ip', method: :mask_ip },
    ]
  end

  def scope
    ActivityLog.where(updated_at: ...request.data_older_than)
  end

  def erase(activity_log)
    erase_fields(activity_log, fields)
  end
end
