require 'spec_helper'

elasticsearch_rest_api_port = 9200
elasticsearch_communication_port = 9300

describe 'Checking if Elasticsearch service is running' do
  describe service('elasticsearch') do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'Checking if Elasticsearch user exists' do
  describe group('elasticsearch') do
    it { should exist }
  end
  describe user('elasticsearch') do
    it { should exist }
    it { should belong_to_group 'elasticsearch' }
  end
end

describe 'Checking Elasticsearch directories and config files' do
  let(:disable_sudo) { false }
  describe file('/etc/elasticsearch') do
    it { should exist }
    it { should be_a_directory }
  end
  describe file("/etc/elasticsearch/elasticsearch.yml") do
    it { should exist }
    it { should be_a_file }
  end
end

describe 'Checking if the ports are open' do
  let(:disable_sudo) { false }
  describe port(elasticsearch_rest_api_port) do
    it { should be_listening }
  end
  describe port(elasticsearch_communication_port) do
    it { should be_listening }
  end
end 

describe 'Checking Elasticsearch HTTP status code' do
  let(:disable_sudo) { false }
  describe command("curl -o /dev/null -s -w '%{http_code}' $(grep 'network.host' /etc/elasticsearch/elasticsearch.yml | awk '{print $2}'):#{elasticsearch_rest_api_port}") do
    it "is expected to be equal" do
      expect(subject.stdout.to_i).to eq 200
    end
  end
end

describe 'Checking Elasticsearch health' do
  let(:disable_sudo) { false }
  describe command("curl $(grep 'network.host' /etc/elasticsearch/elasticsearch.yml | awk '{print $2}'):#{elasticsearch_rest_api_port}/_cluster/health?pretty=true") do
    its(:stdout_as_json) { should include('status' => /green|yellow/) }
    its(:exit_status) { should eq 0 }
  end
end
