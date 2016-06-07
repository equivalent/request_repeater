require 'spec_helper'
require 'time'

describe RequestRepeater::Endpoint do
  let(:subject)  { described_class.new(url: url, sleepfor: sleepfor) }
  let(:url)      { 'http://bring-me-the-horizon' }
  let(:sleepfor) { 6666 }
  let(:dummy_timer) { double(:dummy_timer, now: dummy_time_object) }
  let(:dummy_time_object) { Time.parse("Thu Oct 27 16:00:20 GMT 2016") }

  describe '#url' do
    context 'when url is provided' do
      it 'returns the url' do
        expect(subject.url).to eq url
      end
    end

    context 'when url is not provided' do
      let(:url) { nil }

      it do
        expect { subject.url }.to raise_error(RequestRepeater::Endpoint::NoEndpointToCall)
      end
    end
  end

  describe '#uri' do
    let(:uri) { subject.uri }

    context 'when valid url provided' do
      let(:url) { 'https://myapp.com/healhcheck' }

      it 'should parse it to URI as it is' do
        expect(uri.scheme).to eq 'https'
        expect(uri.port).to eq 443
        expect(uri.host).to eq 'myapp.com'
        expect(uri.path).to eq '/healhcheck'
      end
    end

    context 'when valid url provided withotu path' do
      let(:url) { 'http://myapp.com' }

      it 'should parse it and point path to root' do
        expect(uri.scheme).to eq 'http'
        expect(uri.port).to eq 80
        expect(uri.host).to eq 'myapp.com'
        expect(uri.path).to eq '/'
      end
    end

    context 'when url without scheme' do
      let(:url) { 'myapp.com/health' }

      it do
        expect { uri }.to raise_exception(RequestRepeater::Endpoint::InvalidURL)
      end
    end
  end



  describe '#execute' do
    let(:block_spy) { spy }

    def trigger
      subject.execute do
        block_spy.call
      end
    end

    context 'when executable' do
      before do
        expect(subject).to receive(:executable?).and_return(true)
      end

      it 'should execute the block' do
        trigger
        expect(block_spy).to have_received(:call)
      end
    end

    context 'when not executable' do
      before do
        expect(subject).to receive(:executable?).and_return(false)
      end

      it 'should execute the block' do
        trigger
        expect(block_spy).not_to have_received(:call)
      end
    end
  end

  describe '#executable?' do
    before do
      subject.timer = dummy_timer
    end

    context 'when called in time not yet allowed' do
      before do
        subject.last_execution = dummy_time_object - RequestRepeater.sleeptime(6500)
      end

      it do
        expect(subject).not_to be_executable
      end
    end

    context 'when called in allowed time' do
      before do
        subject.last_execution = dummy_time_object - RequestRepeater.sleeptime(6700)
      end

      it do
        expect(subject).to be_executable
      end
    end
  end

  describe '#last_execution' do
    before do
      subject.timer = dummy_timer
    end

    context 'not executed' do
      it do
        expect(subject.last_execution).to be nil
      end
    end

    context 'after #executed' do
      it 'should be marked as now' do
        subject.executed
        expect(subject.last_execution).to eq dummy_time_object
      end
    end
  end
end
