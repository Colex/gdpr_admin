# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GdprAdmin::RequestProcessorJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    let(:request) { instance_double('GdprAdmin::Request') }

    it 'calls #process! on the request' do
      allow(request).to receive(:process!)
      job.perform(request)
      expect(request).to have_received(:process!).with(no_args).once
    end
  end
end
