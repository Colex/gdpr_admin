# frozen_string_literal: true

module PaperTrail
  class VersionDataPolicy < GdprAdmin::PaperTrail::VersionDataPolicy
    def fields
      [
        { field: 'ip', method: :anonymize_ip },
      ]
    end
  end
end
