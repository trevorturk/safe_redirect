require 'spec_helper'

module SafeRedirect
  describe SafeRedirect do
    class Controller
      extend SafeRedirect
    end
  
    before(:all) do
      load_config
    end

    SAFE_PATHS = [
      'https://www.bukalapak.com',
      '/',
      '/foobar',
      'http://www.twitter.com',
      'http://blah.foo.org',
      'http://foo.org',
      'http://foo.org/',
      :back,
      ['some', 'object'],
      { controller: 'home', action: 'index' },
    ]

    UNSAFE_PATHS = [
      "https://www.bukalapak.com@google.com",
      "http://////@@@@@@attacker.com//evil.com",
      "//bukalapak.com%25%40%25%40%25%40%25%40%25%40%25%40%25%40evil.com",
      "evil.com",
      ".evil.com",
      "%@%@%@%@%@%@%@%@%@%@evil.com",
      "https://www-bukalapak.com",
      "https://www.bukalapak.com\n.evil.com",
      "http://blah.blah.foo.org",
    ]

    SAFE_PATHS.each do |path|
      it "considers #{path} a safe path" do
        expect(Controller.safe_path(path)).to eq(path)
      end
    end

    UNSAFE_PATHS.each do |path|
      it "considers #{path} an unsafe path" do
        expect(Controller.safe_path(path)).to eq(SafeRedirect.configuration.default_path)
      end
    end

    it 'filters host, port, and protocol options when hash is passed to safe_path' do
      hash = { host: 'yahoo.com', port: 80, protocol: 'https', controller: 'home', action: 'index' }
      safe_hash = { port: 80, protocol: 'https', controller: 'home', action: 'index' }
      expect(Controller.safe_path(hash)).to eq(safe_hash)
    end

    it 'can use redirect_to method with only the target path' do
      Controller.redirect_to '/'
    end

    it 'can use redirect_to method with both the target path and the options' do
      Controller.redirect_to '/', notice: 'Back to home page'
    end
  end
end
