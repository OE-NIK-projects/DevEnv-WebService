#!/usr/bin/env pwsh

$cmds = @"
put router/*.rsc
bye
"@

$cmds | sftp 'admin@192.168.1.254'
