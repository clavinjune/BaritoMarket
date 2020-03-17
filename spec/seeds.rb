# Default dummy seeds

::FactoryBot.create(:group, name: "barito-superadmin")
::FactoryBot.create(:group, name: Figaro.env.global_viewer_role)
%w(yggdrasil consul zookeeper kafka elasticsearch barito-flow-producer barito-flow-consumer kibana).each do |n|
  case n
  when "consul"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/consul-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "consul": {
                "hosts": []
            },
            "run_list": []
          }
      }]
    )
  when "zookeeper"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/zookeeper-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "consul":{
              "hosts":[],
              "run_as_server":false
            },
            "datadog":{
              "zk":{
                "instances":[{"host":"localhost", "port":2181, "tags":[], "cluster_name":""}]
              },
              "datadog_api_key":"",
              "datadog_hostname":""
            },
            "run_list":[],
            "zookeeper":{"hosts":[""],"my_id":""}
          }
      }]
    )
  when "kafka"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/kafka-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "kafka":{
              "kafka":{"hosts":[]},
              "zookeeper":{"hosts":[]}
            },
            "consul":{
              "hosts":[],
              "run_as_server":false
            },
            "datadog":{
              "kafka":{
                "instances":[{"host":"localhost", "port":8090, "tags":[], "cluster_name":""}]
              },
              "datadog_api_key":"",
              "datadog_hostname":""
            },
            "run_list":[]
          }
      }]
    )
  when "elasticsearch"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
        bootstrap_type: "chef-solo",
        bootstrap_cookbooks_url: "https://github.com/BaritoLog/elasticsearchwrapper_cookbook/archive/master.tar.gz",
        bootstrap_attributes: {
          "consul":{
            "hosts":[],
            "run_as_server":false
          },
          "datadog":{
            "elastic":{
              "instances":[{"url":"", "tags":[]}]
            },
            "datadog_api_key":"",
            "datadog_hostname":""
          },
          "run_list":[],
          "elasticsearch":{
            "version":"6.3.0",
            "allocated_memory":12000000,
            "max_allocated_memory":16000000,
            "cluster_name":"",
            "index_number_of_replicas":0,
            "minimum_master_nodes":1
          }
        }
      }]
    )
  when "barito-flow-producer"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "consul":{
              "hosts":[],
              "run_as_server":false
            },
            "run_list":[],
            "barito-flow":{
              "producer":{
                "version":"v0.11.8",
                "env_vars":{
                  "BARITO_PRODUCER_ADDRESS":":8080",
                  "BARITO_CONSUL_URL":"http://consul.service.consul:8500",
                  "BARITO_CONSUL_KAFKA_NAME":"kafka",
                  "BARITO_KAFKA_BROKERS":"kafka.service.consul:9092",
                  "BARITO_KAFKA_PRODUCER_TOPIC":"barito-log",
                  "BARITO_PRODUCER_MAX_TPS":0,
                  "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL":10
                }
              }
            }
          }
      }]
    )
  when "barito-flow-consumer"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz",
          bootstrap_attributes: {
            "consul":{
              "hosts":[],
              "run_as_server":false
            },
            "run_list":[],
            "barito-flow":{
              "consumer":{
                "version":"v0.11.8",
                "env_vars":{
                  "BARITO_CONSUL_URL":"http://consul.service.consul:8500",
                  "BARITO_CONSUL_KAFKA_NAME":"kafka",
                  "BARITO_CONSUL_ELASTICSEARCH_NAME":"elasticsearch",
                  "BARITO_KAFKA_BROKERS":"kafka.service.consul:9092",
                  "BARITO_KAFKA_GROUP_ID":"barito-group",
                  "BARITO_KAFKA_CONSUMER_TOPICS":"barito-log",
                  "BARITO_ELASTICSEARCH_URLS":"http://elasticsearch.service.consul:9200",
                  "BARITO_PUSH_METRIC_URL":""
                }
              }
            }
          }
      }]
    )
  when "kibana"
    ::FactoryBot.create(:deployment_template,
      name: n,
      bootstrappers: [{
          bootstrap_type: "chef-solo",
          bootstrap_cookbooks_url: "https://github.com/BaritoLog/kibana_wrapper_cookbook",
          bootstrap_attributes: {
            "consul":{
              "hosts":[],
              "run_as_server":false
            },
            "kibana":{
              "config":{
                "server.basePath":"",
                "elasticsearch.url":"http://elasticsearch.service.consul:9200"
              },
              "version":"6.3.0"
            },
            "run_list":[]
          }
      }]
    )
  else
    ::FactoryBot.create(:deployment_template, name: n)
  end
end
