# frozen_string_literal: true

module GdprAdmin
  class Task < ApplicationRecord
    belongs_to :tenant, class_name: 'Organization'
    belongs_to :requester, class_name: 'AdminUser'

    enum status: {
      pending: 'pending',
      processing: 'processing',
      completed: 'completed',
      failed: 'failed',
    }
    enum request: {
      subject_export: 'subject_export',
      erase_all: 'erase_all',
      erase_subject: 'erase_subject',
      erase_timeframe: 'erase_timeframe',
    }
  end
end
