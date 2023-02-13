# frozen_string_literal: true

module GdprAdmin
  class ApplicationDataPolicy
    def initialize(request)
      @request = request
    end

    def scope
      raise SkipDataPolicyError
    end

    def export(_record)
      raise NotImplementedError
    end

    def erase(_record)
      raise NotImplementedError
    end

    protected

    attr_reader :request
  end
end
