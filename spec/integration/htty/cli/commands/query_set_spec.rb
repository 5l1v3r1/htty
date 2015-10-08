require 'htty/cli/commands/query_set'
require 'htty/session'

RSpec.describe HTTY::CLI::Commands::QuerySet do
  let :klass do
    subject.class
  end

  let :session do
    HTTY::Session.new nil
  end

  def instance(*arguments)
    klass.new session: session, arguments: arguments
  end

  describe 'without an argument' do
    it 'should raise an error' do
      expect{instance.perform}.to raise_error(ArgumentError)
    end
  end

  describe 'with one argument' do
    it 'should assign a single key' do
      instance('test').perform
      expect(session.requests.last.uri.query).to eq('test')
    end
  end

  describe 'with two arguments' do
    it 'should assign a key-value pair' do
      instance('test', 'true').perform
      expect(session.requests.last.uri.query).to eq('test=true')
    end
  end

  describe 'with three arguments' do
    it 'should assign a key-value pair and a valueless key' do
      instance('test', 'true', 'more').perform
      expect(session.requests.last.uri.query).to eq('test=true&more')
    end
  end

  describe 'with four arguments' do
    it 'should assign two key-value pairs' do
      instance('test', 'true', 'more', 'false').perform
      expect(session.requests.last.uri.query).to eq('test=true&more=false')
    end
  end

  describe 'with duplicate keys' do
    it 'should replace existing key' do
      session.requests.last.uri.query = 'test=true'
      instance('test', 'false').perform
      expect(session.requests.last.uri.query).to eq('test=false')
    end

    it 'should maintain field location' do
      session.requests.last.uri.query = 'test=true&more=true'
      instance('test', 'false').perform
      expect(session.requests.last.uri.query).to eq('test=false&more=true')
    end

    it 'should replace multiple instances with one' do
      session.requests.last.uri.query = 'test=true&more=true&test=true'
      instance('test', 'false').perform
      expect(session.requests.last.uri.query).to eq('test=false&more=true')
    end

    it 'should play nice with nested fields' do
      instance('test[my][]', '1').perform
      instance('test[my][]', '2').perform
      instance('test', '3').perform
      expect(session.requests.last.uri.query).to eq('test%5Bmy%5D%5B%5D=2&test=3')
    end
  end
end
