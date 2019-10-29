# Graylog Configuration

## Windows Event Logs

Collect event logs from windows server, using `winlogbeat`.

Audit windows event logs for:

- Logon/Logoff events
- Object deleted events
- AD/Object created events
- Printed job events

### Windows Audit policy configuration

Setting windows audit policy, detemine what events to collect.

### Category policy setting

Domain Policy/Computer Configuration/Policies/Windows Settings/ Security
Settings/Local Policies/Audit Policies/

### Subcategory policy setting

Domain Policy/Computer Configuration/Policies/Windows Settings/ Security
Settings/Advanced Audit Policies/Audit Policies/

### Graylog configuration

Setting graylog, to collect log and analysis.

- System/Indices
- Steams
- Inputs
- System/Sidecars
- Dashboards
- Alerts

### System/indices

Create index set `WinEventLog`:

```yaml
Index prefix: wineventlog
Shards: 2
Replicas: 1
Field type refresh interval: 5 seconds
Index rotation strategy: Index Time
Rotation period: P1D (1d, a day)
Index retention strategy: Delete
Max number of indices: 100
```

### Streams

Create stream `WinEventLog`:

```
Field **beats_type** must match exactly **winlogbeat**
```

### Inputs

Create input Beats, named `beats`.

```yaml
bind_address: 0.0.0.0
no_beats_prefix: false
number_worker_threads: 4
override_source: <empty>
port: 5044
recv_buffer_size: 1048576
tcp_keepalive: false
tls_cert_file: <empty>
tls_client_auth: disabled
tls_client_auth_cert_file: <empty>
tls_enable: false
tls_key_file: <empty>
tls_key_password: ********
```

### System/Sidecars

Create Configuration `winlogbeat`, and apply the configure file to
windows servers.

Replace <graylog server host> with the actural hostname.

```yaml
# Needed for Graylog
fields_under_root: true
fields.collector_node_id: ${sidecar.nodeName}
fields.gl2_source_collector: ${sidecar.nodeId}

output.logstash:
  hosts: ["<graylog server host>:5044"]
path:
  data: C:\Program Files\Graylog\sidecar\cache\winlogbeat\data
  logs: C:\Program Files\Graylog\sidecar\logs
tags:
  - windowsEventLog
winlogbeat:
  event_logs:
    - name: Application
      ignore_older: 720h
    - name: System
      ignore_older: 720h
    - name: Security
      ignore_older: 720h
    - name: Microsoft-Windows-Sysmon/Operational
      ignore_older: 720h
    - name: Microsoft-Windows-PrintService/Operational
      ignore_older: 720h
logging:
  level: warning
```

### Dashboards

### Alerts

### Install graylog-sidecar on windows server

Configuration:

```yaml
Graylog API: <https://graylog-server/api>
name of this instance: <windows server hostname>
API token: <api token>
```

## Exchange 2010 Message Tracking

Collect exchange tracking messages from windows exchane server, using `filebeat`.

Audit exchange tracking messages for:

- who sent mails
- who received mail

### Graylog Configuration

Setting graylog, to collect log and analysis.

- System/Indices
- Steams
- lookup table
- Inputs
- System/Sidecars
- Dashboards
- Alerts

### System/indices

Create index set `Exchange2010MsgTrk`

```yaml
Index prefix: ex2010msgtrk
Shards: 2
Replicas: 1
Field type refresh interval: 5 seconds
Index rotation strategy: Index Time
Rotation period: P30D (30d, a month)
Index retention strategy: Delete
Max number of indices: 12
```

### Streams

Create stream `Exchange2010MsgTrk`:

    Field **filebeat_tags** must contain **ex2010-msg-trk**

### Lookup Table

Create `Data Adapters`: geoip (Geo IP - MaxMind™ Databases)

```yaml
Description: No description.
Configuration:
  Database file path: /etc/graylog/server/GeoLite2-City.mmdb
  Database type: City database
  Check interval: 1 days
```

Create `Caches`: geoip (Node-local, in-memory cache)

```yaml
Description: No description.
Configuration:
  Maximum entries: 1000
  Expire after access: 60 seconds
  Expire after write: Never
```

Create `Lookup Tables`

```yaml
Data adapter: geoip
Cache: geoip
```

### Inputs

Create input Beats, named `beats_ex2010msgtrk`.

```yaml
bind_address: 0.0.0.0
no_beats_prefix: false
number_worker_threads: 1
override_source: <empty>
port: 5045
recv_buffer_size: 1048576
tcp_keepalive: false
tls_cert_file: <empty>
tls_client_auth: disabled
tls_client_auth_cert_file: <empty>
tls_enable: false
tls_key_file: <empty>
tls_key_password: ********
```

Exchange 2010 tracking message is cvs format, so need to extract.

Create extractors:

- ex2010msgtrk_csv(Copy input)
- ex2010msgtrk_geo(Lookup Table)

- ex2010msgtrk_csv(Copy input):

  > Trying to extract data from message into message, leaving the
  > original intact.

```yaml
Configuration
  No configuration options
Converters
  csv
    column_header:
      date_time,client_ip,client_hostname,server_ip,server_hostname,source_context,connector_id,src,event_id,internal_message_id,message_id,recipient_address,recipient_status,total_bytes,recipient_count,related_recipient_address,reference,message_subject,sender_address,return_path,message_info,directionality,tenant_id,original_client_ip,original_server_ip,custom_data
    trim_leading_whitespace:
```

- ex2010msgtrk_geo(Lookup Table):

  > Trying to extract data from original_client_ip into
  > geo_original_client_ip, leaving the original intact.

```yaml
Configuration
  lookup_table_name: geoip
```

### System/Sidecars

Create Configuration `filebeat-ex2010_msg_trk`, and apply the configure
file to the exchange server.

Replace <graylog server host> with the actural hostname.

```yaml
# Needed for Graylog
fields_under_root: true
fields.collector_node_id: ${sidecar.nodeName}
fields.gl2_source_collector: ${sidecar.nodeId}

filebeat.inputs:
- input_type: log
  paths:
    - C:\Program Files\Microsoft\Exchange Server\V14\TransportRoles\Logs\MessageTracking\*.LOG
  type: log
  ignore_older: 0
  scan_frequency: 30s
  #tail_files: true
  exclude_lines: ['^#']
output.logstash:
  hosts: ["<graylog server host>:5045"]
path:
  data: C:\Program Files\Graylog\sidecar\cache\filebeat\data
  logs: C:\Program Files\Graylog\sidecar\logs
tags:
  - ex2010-msg-trk
fields:
  exchange: 2010
```

### Dashboards

### Alerts

### Install graylog-sidecar on Exchange server

Configuration:

```yaml
Graylog API: <https://graylog-server/api>
name of this instance: <exchange server hostname>
API token: <api token>
```

## 360天擎 Logs

Push 360天擎 logs to graylog-server, using `syslog`.

### 360 Configuration

/系统管理/系统设置/数据导出:

```yaml
SysLog数据:
  目标数据平台IP: <graylog-server ip>
  目标数据平台端口: <graylog-input-syslog port>
常规业务发送项: ['体检分', ‘漏洞管理', '插件', '安全防护']
转发配置: 默认模式(标注JSON)
```

### Graylog Configuration

Setting graylog, to accept logs and analysis.

- System/Indices
- Steams
- Inputs
- Dashboards
- Alerts

### System/indices

Create index set `360TQ`

```yaml
Index prefix: 360tq
Shards: 2
Replicas: 1
Field type refresh interval: 5 seconds
Index rotation strategy: Index Time
Rotation period: P30D (30d, a month)
Index retention strategy: Delete
Max number of indices: 12
```

### Streams

Create stream `360TQ`:

```
Field **tags** must contain **360TQ**
```

### Inputs

Create input Beats, named `syslog/udp_360TQ`.

```yaml
allow_override_date: true
bind_address: 0.0.0.0
expand_structured_data: false
force_rdns: false
number_worker_threads: 1
override_source: <empty>
port: 515
recv_buffer_size: 1048576
store_full_message: false
```

360 push logs with json format, so need extract the logs received.

Create extractors:

- 360TQ_json(json)
- 360TQ_source(Replace with regular expression)

- 360TQ_json(json):

  > Trying to extract data from message into , leaving the original intact.

```yaml
Configuration
  list_separator: ,
  kv_separator: =
  key_prefix:
  key_separator: _
  replace_key_whitespace:
  key_whitespace_replacement: _
```

-   360TQ_source(Replace with regular expression):

  > Trying to extract data from source into source, leaving the
  > original intact.

```yaml
Configuration
  replacement: 360tq
  regex: ^.*$
```

### Dashboards

### Alerts

## ESafeNet Logs

Collect ESafeNet logs from esafenet server, using `filebeat`.

Audit exchange tracking messages for:

- who decode files using privilege auth
- who submit process to decode files

### Graylog Configuration

Setting graylog, to collect log and analysis.

- System/Indices
- Steams
- Inputs
- System/Sidecars
- Dashboards
- Alerts

### System/indices

Create index set `ESafeNet`

```yaml
Index prefix: esafenet
Shards: 2
Replicas: 1
Field type refresh interval: 5 seconds
Index rotation strategy: Index Time
Rotation period: P30D (30d, a month)
Index retention strategy: Delete
Max number of indices: 24
```

### Streams

Create stream `ESafeNet`:

```
Field **filebeat_tags** must contain **esafenet**
```

### Inputs

Create input Beats, named `beats_esafenet`.

```yaml
bind_address: 0.0.0.0
no_beats_prefix: false
number_worker_threads: 1
override_source: <empty>
port: 5046
recv_buffer_size: 1048576
tcp_keepalive: false
tls_cert_file: <empty>
tls_client_auth: disabled
tls_client_auth_cert_file: <empty>
tls_enable: false
tls_key_file: <empty>
tls_key_password: ********
```

ESafeNet log is cvs format, filelog and proclog is in different format.
Another, create timestamp from log time.

Create extractors

- esafenet_filelog(Copy input)
- esafenet_proclog(Copy input)
- esafenet_timestamp_1(Copy input)
- esafenet_timestamp_2(Copy input)

- esafenet_filelog(Copy input):

  > Trying to extract data from message into message, leaving the original intact.

```
Condition
  Will only attempt to run if the message matches the regular expression ^(?!FSN)
Configuration
  No configuration options
Converters
  csv
    column_header:|-
      esn_user,esn_time,esn_type,esn_op,esn_process,esn_src_filename,
      esn_dst_filename,esn_client_ip,esn_log_level,esn_comment
    escape_char: %
```

- esafenet\_proclog(Copy input):

  > Trying to extract data from message into message, leaving the original intact.

```
Condition
  Will only attempt to run if the message matches the regular expression ^FSN
Configuration
  No configuration options
Converters
  csv
    column_header: esn_id,esn_type,esn_user,esn_time,esn_reason,esn_file,esn_status,esn_opinion
    escape_char: %
```

- esafenet_timestamp_1(Copy input):

  > Trying to extract data from esn_time into timestamp, leaving the original intact.

```
Condition
  Will only attempt to run if the message includes the string
Configuration
  No configuration options
Converters
  date
    date_format: yyyy-MM-dd HH:mm:ss
    time_zone: Asia/Shanghai
    locale: zh-CN
```

- esafenet_timestamp_2(Copy input):

  > Trying to extract data from esn_time into timestamp, leaving the original intact.

```
Condition
  Will only attempt to run if the message matches the regular expression ^[^ ]*$
Configuration
  No configuration options
Converters
  date
    date_format: yyyy-MM-ddHH:mm:ss
    time_zone: Asia/Shanghai
    locale: zh-CN
```

### System/Sidecars

Create Configuration `filebeat-esafenet`, and apply the configure file
to esafenet server.

Replace <graylog server host> with the actural hostname.

```yaml
# Needed for Graylog
fields_under_root: true
fields.collector_node_id: ${sidecar.nodeName}
fields.gl2_source_collector: ${sidecar.nodeId}

filebeat.inputs:
- input_type: log
  paths:
    - E:\log\*\*\*.xls
  type: log
  scan_frequency: 60s
  encoding: gbk
  exclude_lines: ['^操作者', '^流程']
output.logstash:
  hosts: ["<graylog server host>:5046"]
path:
  data: C:\Program Files\Graylog\sidecar\cache\filebeat\data
  logs: C:\Program Files\Graylog\sidecar\logs
tags:
  - esafenet
```

### Dashboards

### Alerts

### Install graylog-sidecar on server

Configuration:

```yaml
Graylog API: <https://graylog-server/api>
name of this instance: <server hostname>
API token: <api token>
```

### Export ESafeNet logs

1. Archive log in DLP system every month;
2. Format log files;
3. Place log files in directory `E:\log\[year]\[month]\`.

### Archive log

Logon on to ESafenet DLP system as user `logadmin`.

Archive log at:

  日志管理/文件日志/归档日志

  日志管理/流程日志/归档日志

### Format log

1. Unarchive log files to directory [logdir]
2. format log files, formated log files will output to directory [logdir]/output:
   ```bash
   formatLogs.sh -d [logdir]
   ```

You can download the script here [Script](/file/formatLogs.sh)

### Place log files

Place formated log files to directory `E:\log\[year]\[month]\`

## Kubernetes Logs

## Dashboard

### Active Directory

### Exchange

### Filesystem

### Security
