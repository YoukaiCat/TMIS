# coding: UTF-8
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require 'rspec'
require 'config'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
require_relative '../../src/engine/mailer/mailer'
#~~~~~~~~~~~~~~~~~~~~~~~~~~
describe Mailer do
  it 'should initialize' do
    expect do
      Mailer.new('name@domain.com', 'secret') do
        from    'sender@domain.com'
        to      'receiver@domain.com'
        subject 'Subject'
        body    'Test'
      end
    end.to_not raise_error
  end

  it 'should not initiale unless email valid' do
    expect { Mailer.new('name@domaincom', 'secret') {} }.to raise_error
  end

  it 'should validate email' do
    Mailer.email_valid?('name@domain.com').should eq(true)
    Mailer.email_valid?('').should eq(false)
    Mailer.email_valid?('name@domaincom').should eq(false)
    Mailer.email_valid?('namedomain.com').should eq(false)
    Mailer.email_valid?('name@').should eq(false)
    Mailer.email_valid?('@domain.com').should eq(false)
  end

  it 'should return parts of email' do
    Mailer.new('name@domain.com', 'secret') {}.send(:email_parts)[:local].should eq('name')
    Mailer.new('name@domain.com', 'secret') {}.send(:email_parts)[:domain].should eq('domain.com')
  end
end
