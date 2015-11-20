require 'spec_helper'
require 'yaml'

describe Enc::Node do
  let(:data) { YAML.load_file(fixture('data/nodes.yaml')) }
  subject(:node) { Enc::Node.new(data[name]) }

  context 'when searching for a node' do
    subject { Enc::Node.lookup(query, data) }
    let(:query) { 'dc1-server03' }
    let(:data) { [fixture('data/nodes.yaml')] }

    context 'with a node that exists in the data as a literal' do
      it { is_expected.to be_a Enc::Node }
      it { expect(subject.environment).to eq 'production' }
    end

    context 'with a node that exists in the data as a regex' do
      let(:query) { 'dc1-server04' }

      it { is_expected.to be_a Enc::Node }
      it { expect(subject.environment).to be nil }
      it { expect(subject.classes).to include 'roles::puppet::master' }
    end

    context 'with a node that does not exist in the data' do
      let(:query) { 'dc1-server09' }
      it { is_expected.to be nil }
    end
  end

  context 'when looking up a node that exists in the data' do
    let(:name) { 'dc1-server03' }

    it { is_expected.to respond_to :to_yaml }
    it { is_expected.to respond_to :classes }
    it { is_expected.to respond_to :parameters }

    context '#node' do
      subject { node.node }
      it { is_expected.to include('environment') }
    end

    context '#environment' do
      subject { node.environment }
      it { is_expected.to be_a String }
      it { is_expected.to eq 'production' }
    end

    context '#classes' do
      subject { node.classes }
      it { is_expected.to be_a Array }
      it { is_expected.to include 'base' }
      it { is_expected.to include 'roles::puppet::master' }
    end

    context '#parameters' do
      subject { node.parameters }
      it { is_expected.to be_a Hash }
      it { is_expected.to include('rack' => 'R5') }
      it { is_expected.to include('role' => 'puppet/master') }
    end

    context '#to_yaml' do
      subject { node.to_yaml }
      it { is_expected.to be_a String }
      it { expect(YAML.load node.to_yaml).to be_a Hash }
    end
  end


  context 'when looking up a node that does not exist in the data' do
    let(:name) { 'dc1-server09' }

    context '#node' do
      subject { node.node }
      it { is_expected.to eq nil }
    end

    context '#environment' do
      subject { node.environment }
      it { is_expected.to eq nil }
    end

    context '#classes' do
      subject { node.classes }
      it { is_expected.to eq nil }
    end

    context '#parameters' do
      subject { node.parameters }
      it { is_expected.to eq nil }
    end

    context '#to_yaml' do
      subject { node.to_yaml }
      it { is_expected.to eq nil }
    end
  end
end
