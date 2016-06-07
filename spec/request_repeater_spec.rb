require 'spec_helper'

describe RequestRepeater do
  subject { RequestRepeater }

  it 'has a version number' do
    expect(RequestRepeater::VERSION).not_to be nil
  end

  describe '.run' do
    let(:maker_spy) { instance_double(RequestRepeater::RequestMaker) }

    def trigger
      RequestRepeater.run
    end

    def expect_to_run_requset_maker
      expect(RequestRepeater::RequestMaker)
        .to receive(:new)
        .with(expected_endpoints)
        .and_return(maker_spy)

      expect(maker_spy).to receive(:run)
    end

    before do
      allow(Time)
        .to receive(:now)
        .and_return(Time.parse('2016-02-02 13:14:15'))
    end

    context 'when using ENV["URL"]' do
      let(:url) { 'http://localhost/healthcheck.html' }

      before do
        allow(ENV).to receive(:[]).with("URL").and_return(url)
        allow(ENV).to receive(:[]).with("SLEEPFOR").and_return(sleepfor)
        allow(ENV).to receive(:[]).with("URLS").and_return(nil)
      end

      context 'when sleep provided' do
        let(:sleepfor)  { 3000 }

        let(:expected_endpoints) do
          [
            RequestRepeater::Endpoint.new(url: url, sleepfor: sleepfor ),
          ].each { |e| e.executed }
        end

        it 'runs requset maker on url sleeping for expected sleep time' do
          expect_to_run_requset_maker
          subject.run
        end
      end

      context 'when sleep not provided' do
        let(:sleepfor)  { nil }

        let(:expected_endpoints) do
          [
            RequestRepeater::Endpoint.new(url: url, sleepfor: 1000 ),
          ].each { |e| e.executed }
        end

        it 'runs requset maker on url defaulting sleep to 1000' do
          expect_to_run_requset_maker
          subject.run
        end
      end
    end

    context 'when passing ENV["URLS"]' do
      let(:json_string) do
        {
          "urls"=>[
            {"url"=>"http://nginx/do-some-bg-stuff", "sleep"=>1300},
            {"url"=>"http://nginx/do-some-bg-stuff", "sleep"=>'5555'},
            {"url"=>"http://localhost"},
            {"url"=>"https://www.microservice.some/maintenance", "sleepfor"=>1200000}
          ]
        }.to_json
      end

      let(:expected_endpoints) do
        [
          RequestRepeater::Endpoint.new(url: 'http://nginx/do-some-bg-stuff', sleepfor: 1300 ),
          RequestRepeater::Endpoint.new(url: 'http://nginx/do-some-bg-stuff', sleepfor: 5555 ),
          RequestRepeater::Endpoint.new(url: 'http://localhost', sleepfor: 1000 ),
          RequestRepeater::Endpoint.new(url: 'https://www.microservice.some/maintenance', sleepfor: 1200000 )
        ].each { |e| e.executed }
      end

      before do
        allow(ENV).to receive(:[]).with("URL").and_return(nil)
        allow(ENV).to receive(:[]).with("URLS").and_return(json_string)
      end

      it 'runs request_maker on every endpoint on given times' do
        expect_to_run_requset_maker
        subject.run
      end
    end
  end
end
