require 'spec_helper'
require 'time'
require 'webmock'

describe RequestRepeater::RequestMaker do
  include WebMock::API

  WebMock.enable!

  subject { described_class.new(endpoints) }

  describe '#run' do
    context 'when several enpoints' do
      let(:endpoints) { [endpoint1, endpoint2] }
      let(:endpoint1) { instance_double(RequestRepeater::Endpoint, url: 'http://nginx/') }
      let(:endpoint2) { instance_double(RequestRepeater::Endpoint) }

      before do
        allow(subject).to receive(:loop).and_yield

        stub_request(:get, "http://nginx/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'should query only those endpoints that are executable?' do
        expect(endpoint1).to receive(:execute).and_yield
        expect(endpoint2).to receive(:execute) #no yield
        subject.run
      end

      it 'should log only requests made' do
        allow(endpoint1).to receive(:execute).and_yield
        allow(endpoint2).to receive(:execute) #no yield

        subject.run

        expect(RequestRepeater.logger)
          .to have_received(:info)
          .once
          .with(/request http:\/\/nginx\/ #<Net::HTTPOK:.*>/)
      end
    end

    context 'when https enpoint' do
      let(:endpoints) { [endpoint1] }
      let(:endpoint1) { instance_double(RequestRepeater::Endpoint, url: 'https://www.myapp.eu/whaat') }

      before do
        allow(subject).to receive(:loop).and_yield
        stub_request(:get, "https://www.myapp.eu/whaat").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'should https' do
        expect(endpoint1).to receive(:execute).and_yield
        subject.run
      end
    end

    context 'when naked enpoint' do
      let(:endpoints) { [endpoint1] }
      let(:endpoint1) { instance_double(RequestRepeater::Endpoint, url: 'https://i-dont-have-slash-at-the-end') }

      before do
        allow(subject).to receive(:loop).and_yield
        stub_request(:get, "https://i-dont-have-slash-at-the-end/").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => "", :headers => {})
      end

      it 'should https' do
        expect(endpoint1).to receive(:execute).and_yield
        subject.run
      end
    end
  end
end
