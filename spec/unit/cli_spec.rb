require 'spec_helper'

describe Enc::Cli do
  let(:query) { 'dc1-server03' }
  let(:argv) { ['-n', data, query] }
  subject { Enc::Cli.new(argv) }

  context 'when passing a directory of nodes' do
    let(:data) { fixture('data') }

    context 'when not finding a node' do
      let(:query) { 'dc1-server09' }

      it { is_expected.to be_a Enc::Cli }
      it { expect(subject.found).to be nil }
    end

    context 'when finding a node' do
      it { is_expected.to be_a Enc::Cli }
      it { expect(subject.found).not_to be nil }
      it { expect(subject.found).to be_a Enc::Node }
      it { expect(subject.found.classes.length).to eq 2 }
    end
  end

  context 'when passing a single node file' do
    let(:data) { fixture('data/nodes.yaml') }

    context 'when not finding a node' do
      let(:query) { 'dc1-server09' }

      it { is_expected.to be_a Enc::Cli }
      it { expect(subject.found).to be nil }
    end

    context 'when finding a node' do
      it { is_expected.to be_a Enc::Cli }
      it { expect(subject.found).not_to be nil }
      it { expect(subject.found).to be_a Enc::Node }
      it { expect(subject.found.classes.length).to eq 2 }
    end
  end
end
