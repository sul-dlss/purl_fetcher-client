RSpec.describe PurlFetcher::Client do
  it 'has a version number' do
    expect(PurlFetcher::Client::VERSION).not_to be nil
  end

  context 'when token is provided' do
    subject(:client) { PurlFetcher::Client.configure(url: 'http://127.0.0.1:3000', token: 'abc123') }

    describe '#post' do
      before do
        stub_request(:post, "http://127.0.0.1:3000/test").
           with(
             body: "{}",
             headers: {
             'Accept'=>'application/json',
             'Authorization'=>'Bearer abc123',
             'Content-Type'=>'application/json'
             }).
           to_return(status: 200, body: 'OK')
      end

      it 'adds token to the request' do
        expect(client.post(path: '/test', body: '{}')).to eq('OK')
      end
    end

    describe '#put' do
      before do
        stub_request(:put, "http://127.0.0.1:3000/test").
           with(
             body: "{}",
             headers: {
             'Accept'=>'application/json',
             'Authorization'=>'Bearer abc123',
             'Content-Type'=>'application/json'
             }).
           to_return(status: 200, body: 'OK')
      end

      it 'adds token to the request' do
        expect(client.put(path: '/test', body: '{}')).to eq('OK')
      end
    end

    describe '#delete' do
    context 'when successful' do
        before do
          stub_request(:delete, "http://127.0.0.1:3000/test").
            with(
              headers: {
              'Accept'=>'application/json',
              'Authorization'=>'Bearer abc123',
              'Content-Type'=>'application/json'
              }).
            to_return(status: 200, body: 'OK')
        end

        it 'adds token to the request' do
          expect(client.delete(path: '/test')).to eq('OK')
        end
      end
    end

    context 'when already deleted' do
      before do
        stub_request(:delete, "http://127.0.0.1:3000/test").
          with(
            headers: {
            'Accept'=>'application/json',
            'Authorization'=>'Bearer abc123',
            'Content-Type'=>'application/json'
            }).
          to_return(status: 409, body: 'already deleted')
      end

      it 'adds token to the request' do
        expect { client.delete(path: '/test') }.to raise_error(PurlFetcher::Client::AlreadyDeletedResponseError, 'already deleted')
      end
    end
  end
end
