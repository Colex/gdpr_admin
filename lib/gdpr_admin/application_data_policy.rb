# frozen_string_literal: true

module GdprAdmin
  class ApplicationDataPolicy
    include Helpers::DataPolicyHelper
    include Helpers::EraseHelper
    include Helpers::ScopeHelper

    class << self
      attr_reader :before_process_hooks, :before_process_record_hooks

      def before_process(method)
        @before_process_hooks ||= []
        @before_process_hooks << method
      end

      def before_process_record(method)
        @before_process_record_hooks ||= []
        @before_process_record_hooks << method
      end

      def process(request)
        new(request).process
      end
    end

    def initialize(request)
      @request = request
    end

    def scope
      skip_data_policy!
    end

    def export(_record)
      raise NotImplementedError
    end

    def erase(_record)
      raise NotImplementedError
    end

    def process
      GdprAdmin.config.tenant_adapter.with_tenant(request.tenant) do
        run_preprocessors
        process_scope
      rescue SkipDataPolicyError
        nil
      end
    end

    def process_scope
      policy_scope.find_each do |record|
        process_record(record)
      end
    end

    protected

    attr_reader :request

    def policy_scope
      return subject_scope if request.subject_request? && respond_to?(:subject_scope)

      scope
    end

    def process_record(record)
      run_record_preprocessors(record)
      export(record) if request.export?
      erase(record) if request.erase?
    rescue SkipRecordError
      nil
    end

    def run_preprocessors
      before_process_hooks = self.class.before_process_hooks || []
      before_process_hooks.each do |hook|
        call_hook(hook)
      end
    end

    def run_record_preprocessors(record)
      before_process_record_hooks = self.class.before_process_record_hooks || []
      before_process_record_hooks.each do |hook|
        call_hook(hook, record)
      end
    end

    def call_hook(hook, value = nil)
      hook = method(hook) unless hook.respond_to?(:call)

      arity = arity_of(hook)
      args = [value].take(arity).reverse
      instance_exec(*args, &hook)
    end

    def arity_of(method_or_proc)
      defined?(T::Utils.arity) ? T::Utils.arity(method_or_proc) : method_or_proc.arity
    end
  end
end
