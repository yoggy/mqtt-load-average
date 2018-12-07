#!/usr/bin/ruby
require 'mqtt'
require 'yaml'
require 'ostruct'
require 'json'
require 'time'
require 'pp'

$stdout.sync = true

$log = Logger.new(STDOUT)
$log.level = Logger::DEBUG

$conf = OpenStruct.new(YAML.load_file(File.dirname($0) + '/config.yaml'))

conn_opts = {
  "remote_host" => $conf.host,
  "remote_port" => $conf.port
}
if $conf.use_auth
  conn_opts["username"] = $conf.username
  conn_opts["password"] = $conf.password
end

MQTT::Client.connect(conn_opts) do |c|
  loop do 
    rv = `uptime`

    a = rv.split(" ")
    d = {}
    d["t"] = Time.now.iso8601
    d["1min"] = a[7][0, a[7].size-1].to_f
    d["5min"] = a[8][0, a[8].size-1].to_f
    d["15min"] = a[9].to_f

    topic = $conf.publish_topic

    $log.info("publish:topic=" + topic + "payload=" + d.to_json)
    c.publish(topic, d.to_json, true)

    sleep 10
  end
end

