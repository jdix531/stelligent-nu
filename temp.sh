cat <<'EOF' >> /tmp/json
{
"agent": {
"metrics_collection_interval": 60,
"run_as_user": "root"
},
"metrics": {
"append_dimensions": {
"AutoScalingGroupName": "${aws:AutoScalingGroupName}",
"ImageId": "${aws:ImageId}",
"InstanceId": "${aws:InstanceId}",
"InstanceType": "${aws:InstanceType}"
},
"metrics_collected": {
"disk": {
  "measurement": [
    "used_percent"
  ],
  "metrics_collection_interval": 60,
  "resources": [
    "*"
  ]
},
"mem": {
  "measurement": [
    "mem_used_percent"
  ],
  "metrics_collection_interval": 60
}
}
}
}
EOF
