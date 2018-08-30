分片多的话可以提升建立索引的能力，5~20个比较合适，分片数过少或过多都会导致检索比较慢。
分片数过多会导致检索时打开较多文件，另外也会导致多台服务器间通讯，而分片数过少会导至单个分片索引过大，所以检索速度也会慢。
建议单个分片最多存储20G左右的索引数据，所以分片数量=数据总量/20G
-------------------------------------------------
#显示集群系统信息，包括CPU JVM等等
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/stats?pretty=true

#集群的详细信息。包括节点、分片等
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/state?pretty=true

#获取集群堆积的任务
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_cluster/pending_tasks?pretty=true
{
  "tasks" : []
}

#修改集群配置 ( transient 表示临时的，persistent表示永久的 )
#举例：
[wangyu@localhost Test]$ curl -XPUT localhost:9200/_cluster/settings -d '{
    "persistent" : {
        "discovery.zen.minimum_master_nodes" : 2
    }
}'

#统计ES某个索引数据量：
[wangyu@localhost Test]$ curl -XGET '10.110.79.22:9200/_cat/count/new-sgs-rbil-core-sys

#获取mapping
[wangyu@localhost Test]$ curl -XGET http://localhost:9200/{index}/{type}/_mapping?pretty

#查看模板：
[wangyu@localhost Test]$ curl -XGET 10.116.182.65:9200/_template/fvp_waybillnewstatus_template

#关闭指定192.168.1.1节点
[wangyu@localhost Test]$ curl -XPOST 'http://localhost:9200/_cluster/nodes/192.168.1.1/_shutdown'

#查看所有的索引文件
[wangyu@localhost Test]$ curl localhost:9200/_cat/indices?v
health status index               pri rep docs.count docs.deleted store.size pri.store.size 
yellow open   filebeat-2015.12.24   5   1       3182            0        1mb            1mb 
yellow open   logstash-2015.12.23   5   1        100            0    235.8kb        235.8kb 
yellow open   logstash-2015.12.22   5   1         41            0    126.5kb        126.5kb 
yellow open   .kibana               1   1         94            0    102.3kb        102.3kb 

#删除索引文件以释放空间
curl -XDELETE http://10.0.0.3:9200/filebeat-2016.12.28

#查看ES集群中各节点的磁盘使用率
[wangyu@localhost ~]$ curl -XGET 10.0.0.3:9200/_cat/allocation?v
shards disk.indices disk.used disk.avail disk.total disk.percent host     ip       node
     7      173.1kb       3gb     14.4gb     17.4gb           17 10.0.0.3 10.0.0.3 node1

#返回状态非404的
curl -XGET 'localhost:9200/logstash-2015.12.23/_search?q=response=404&pretty'

#查来自Buffalo的
curl -XGET 'localhost:9200/logstash-2015.12.23/_search?q=geoip.city_name:Buffalo&pretty'

#查看节点状态
#get _nodes/hot_threads
#get _nodes/node-1/hot_threads

#查看集群负载相关信息
[root@node3 elasticsearch]# curl -X GET http://localhost:9200/_cat/nodes?v      
host        ip          heap.percent ram.percent load node.role master name 
192.168.0.7 192.168.0.7            5          76 0.25 d         m      node3
192.168.0.6 192.168.0.6            6          67 0.16 d         *      node2 
192.168.0.5 192.168.0.5            5          68 0.08 d         m      node1   

#查看集群health相关信息
[root@node1 ~]# curl -X GET http://localhost:9200/_cluster/health?pretty
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 3,
  "number_of_data_nodes" : 3,
  "active_primary_shards" : 0,
  "active_shards" : 0,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

#迁移节点分片
curl -XPOST '172.18.1.22:9200/_cluster/reroute' -d  '{
    "commands" : [
        {
            "move" : {
                "index" : "info-test", "shard" : 3,
                "from_node" : "172.18.1.26", "to_node" : "172.18.1.25"
            }
        }
    ]
}'

#查看当前节点health相关信息
[root@node3 ~]# curl -X GET http://localhost:9200/_cat/health                   
1514807391 19:49:51 elasticsearch green 1 1 0 0 0 0 0 0 - 100.0%

#监视集群中的挂起任务，类似于创建索引、更新映射、分配碎片、故障碎片等
GET http://localhost:9200/_cluster/pending_tasks

#同时为多个索引映射到一个索引别名
curl -XPOST 'http://192.168.80.10:9200/_aliases' -d '
{
    "actions" : [
        { "add" : { "index" : "zhouls", "alias" : "zhouls_all" } },
        { "add" : { "index" : "zhouls10", "alias" : "zhouls_all" } }
    ]
}'

#删除索引zhouls映射的索引别名zhouls_all
curl -XPOST 'http://192.168.80.10:9200/_aliases' -d '
{
    "actions" : [
        { "remove" : { "index" : "zhouls", "alias" : "zhouls_all" } }
    ]
}'

#索引统计
GET my_index/_stats
GET my_index,another_index/_stats
GET _all/_stats
