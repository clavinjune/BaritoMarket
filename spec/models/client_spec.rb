require 'rails_helper'

RSpec.describe Client, type: :model do

  context 'associations' do
    it 'belongs to stream' do
      assc = described_class.reflect_on_association(:stream)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to store' do
      assc = described_class.reflect_on_association(:store)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to forwarder' do
      assc = described_class.reflect_on_association(:forwarder)
      expect(assc.macro).to eq :belongs_to
    end
  end

  context 'name' do
    it 'must be presence' do
      client = FactoryGirl.build(:client, name: '')
      expect(client).to_not be_valid
    end
  end

  context 'when client created' do
    it 'copy kafka topics from forwarder' do
      client = FactoryGirl.create(:client)
      expect(client.kafka_topics).to eq(client.forwarder.kafka_topics)
    end

    it 'generate produce url' do
      stream = FactoryGirl.create(:stream, id: 1, receiver_host: 'some-host', receiver_port: 'some-port')
      store = FactoryGirl.create(:store, id: 2)
      forwarder = FactoryGirl.create(:forwarder, id: 3, kafka_topics: 'kafka-topics')
      client = FactoryGirl.create(:client, stream: stream, store: store, forwarder: forwarder, id: 4)

      expect(client.produce_url).to eq('http://some-host:some-port/str/1/st/2/fw/3/sv/4/produce/kafka-topics')
    end

    it 'setup forwarder' do
      client = FactoryGirl.create(:client)
      expect(client.stream).to eq(client.forwarder.stream)
      expect(client.store).to eq(client.forwarder.store)
    end

    it 'copy kibana host from store' do
      client = FactoryGirl.create(:client)
      expect(client.kibana_host).to eq(client.store.kibana_host)
    end

    it 'copy kafka topic partition from stream' do
      client = FactoryGirl.create(:client)
      expect(client.kafka_topic_partition).to eq(client.stream.kafka_topic_partition)
    end
  end

end
