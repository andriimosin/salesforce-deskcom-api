require 'spec_helper'
require 'desk/resource/page'

describe Desk::Resource::Page do
  subject do
    @client ||= Desk::Client.new Desk::CONFIG
  end

  context '#query_params' do
    before do
      @page = Desk::Resource::Page.new(subject, Hashie::Mash.new({
        _links: { self: { href: '/api/v2/cases?page=2&per_page=50' } }
      }), true)
    end

    it 'allows to get query params from the current resource' do
      @page.send(:query_params, 'page').should eq('2')
      @page.send(:query_params, 'per_page').should eq('50')
    end

    it 'returns nil if param not found' do
      @page.send(:query_params, 'blup').should be_nil
    end
  end

  context '#query_params=' do
    before do
      @page = Desk::Resource::Page.new(subject, Hashie::Mash.new({
        _links: { self: { href: '/api/v2/cases' } }
      }), true)
    end

    it 'sets query params on the current url' do
      @page.send(:query_params=, { page: 5, per_page: 50 })
      @page.instance_variable_get(:@_links).self.href.should eq('/api/v2/cases?page=5&per_page=50')
    end
  end

  context '#page' do
    it 'returns the current page and loads if page not defined', :vcr do
      subject.articles.page.should eq(1)
    end

    it 'sets the page' do
      subject.cases.page(5).page.should eq(5)
    end

    it 'sets the resource to not loaded', :vcr do
      cases = subject.cases.send(:exec!)
      cases.page(5).instance_variable_get(:@loaded).should be_false
    end

    it 'keeps the resource as loaded', :vcr do
      cases = subject.cases.send(:exec!)
      cases.page(1).instance_variable_get(:@loaded).should be_true
    end
  end

  context '#by_id' do
    it 'loads the requested resource', :vcr do
      subject.cases.by_id(3065).subject.should eq('Testing the Tank again')
    end
  end
end