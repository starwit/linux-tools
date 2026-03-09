[Unit]
Description=Recorder Service
After=multi-user.target
After=time-sync.target
Wants=time-sync.target

[Service]
Type=simple
ExecStartPre=/bin/bash /opt/recorder/recorder-cleanup.sh
ExecStart=/bin/bash /opt/recorder/recorder.sh
Restart=always
RestartSec=2
StartLimitBurst=20
User=root
# These only work in systemd>=254
RestartSteps=10
RestartMaxDelaySec=30

[Install]
WantedBy=multi-user.target