From: Eric Ren <zren@suse.com>
Date: Thu, 14 Dec 2017 23:01:53 +0800
Subject: [PATCH] test: lvmetad_dump always timed out when using nc
In-Reply-To: <b831437a-598f-ff68-5e24-55ccd8dbaebe@redhat.com>
References: <20171213111303.24775-1-zren@suse.com>
	<02180207-fc63-f9c2-64b0-82224eef1a3e@suse.com>
	<4b234d1c-be10-beba-642f-32bb5dc01ff4@redhat.com>
	<2863cb23-45f1-7eee-e446-9995bf78262f@suse.com>
	<b831437a-598f-ff68-5e24-55ccd8dbaebe@redhat.com>
Message-ID: <c63459b9-1580-ce7d-329c-2c47785bd274@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> While the trace shows nothing wrong - isn't this same issue as you had 
> with dmeventd ?

log2.txt - the log of the blocked one shows it blocks at "not nc -U ..." 
until Ctr+c to teardown:

```
[ 0:01] aux lvmetad_dump | tee lvmetad.txt
[ 0:01] #lvmetad-dump.sh:22+ tee lvmetad.txt
[ 0:01] #lvmetad-dump.sh:22+ aux lvmetad_dump
[ 0:01] + test -f DEVICES
[ 0:01] + devs='@TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:01] @TESTDIR@/dev/mapper/@PREFIX at pv2'
[ 0:01] + test lvmetad_dump = dmsetup
[ 0:01] + lvmetad_dump
[ 0:01] + echo 'request="dump"'
[ 0:01] + echo '##'
[ 0:01] + lvmetad_talk
[ 0:01] + local use=nc
[ 0:01] + type -p socat
[ 0:01] + echo
[ 0:01] + not nc -U @TESTDIR@/lvmetad.socket
[ 0:01] aux teardown
[ 1:24] ##lvmetad-dump.sh:1+ aux teardown
```
>
> Both services needs to be masked together with their sockets on 
> testing machine for testing services (unless you build test package 
> which then is able to run with installed binaries)
>
> Although the socket for testing should be different from 'real one'.

Both lvm2-lvmetad.[service|socket] are disabled/stopped:
```
tw1:~/lvm2/test # systemctl status lvm2-lvmetad.service
? lvm2-lvmetad.service - LVM2 metadata daemon
 ?? Loaded: loaded (/usr/lib/systemd/system/lvm2-lvmetad.service; 
static; vendor preset: disabled)
 ?? Active: inactive (dead)
 ???? Docs: man:lvmetad(8)
tw1:~/lvm2/test # systemctl status lvm2-lvmetad.socket
? lvm2-lvmetad.socket - LVM2 metadata daemon socket
 ?? Loaded: loaded (/usr/lib/systemd/system/lvm2-lvmetad.socket; 
disabled; vendor preset: enabled)
 ?? Active: inactive (dead) since Thu 2017-12-14 21:11:04 CST; 1h 52min ago
 ???? Docs: man:lvmetad(8)
 ?? Listen: /run/lvm/lvmetad.socket (Stream)

Dec 14 21:11:04 tw1 systemd[1]: Closed LVM2 metadata daemon socket.
```

>
> but anyway - you need to provide trace from blocking run:
>
> make check_lvmetad T=lvmetad-dump? VERBOSE=1 LVM_TEST_AUX_TRACE=1 
> &>/tmp/log.txt

tw1:~/lvm2/test # make check_lvmetad T=lvmetad-dump? VERBOSE=1 
LVM_TEST_AUX_TRACE=1 &>/tmp/log3.txt
^C

log3.txt attached.

Thanks,
Eric
-------------- next part --------------
make -C api device-mapper
make[1]: Entering directory '/root/lvm2/test/api'
make[1]: Nothing to be done for 'device-mapper'.
make[1]: Leaving directory '/root/lvm2/test/api'
make -C unit device-mapper
make[1]: Entering directory '/root/lvm2/test/unit'
make[1]: Nothing to be done for 'device-mapper'.
make[1]: Leaving directory '/root/lvm2/test/unit'
make -C api
make[1]: Entering directory '/root/lvm2/test/api'
make[1]: Nothing to be done for 'all'.
make[1]: Leaving directory '/root/lvm2/test/api'
make -C unit
make[1]: Entering directory '/root/lvm2/test/unit'
make[1]: Nothing to be done for 'all'.
make[1]: Leaving directory '/root/lvm2/test/unit'
touch .tests-stamp
VERBOSE=1 ./lib/runner \
	--testdir . --outdir results \
	--flavours ndev-lvmetad --only lvmetad-dump --skip @ 
running 1 tests

[ 0:00] Library version:   1.02.146-git (2017-11-03)
[ 0:00] Driver version:    4.36.0
[ 0:00] Kernel is Linux tw1 4.13.5-1-default #1 SMP PREEMPT Thu Oct 5 18:28:26 UTC 2017 (3fd9659) x86_64 x86_64 x86_64 GNU/Linux
[ 0:00] Selinux mode is not installed.
[ 0:00]               total        used        free      shared  buff/cache   available
[ 0:00] Mem:            974         203          68           0         702         616
[ 0:00] Swap:          2053          90        1963
[ 0:00] Filesystem      Size  Used Avail Use% Mounted on
[ 0:00] devtmpfs        993M  8.0K  993M   1% /dev
[ 0:00] tmpfs          1000M     0 1000M   0% /dev/shm
[ 0:00] tmpfs          1000M  1.3M  998M   1% /run
[ 0:00] tmpfs          1000M     0 1000M   0% /sys/fs/cgroup
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /usr/local
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /.snapshots
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /boot/grub2/x86_64-efi
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/crash
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/cache
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/opt
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /opt
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/named
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/log
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/pgsql
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/mariadb
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /tmp
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/mysql
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/spool
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /srv
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /boot/grub2/i386-pc
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/tmp
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/libvirt/images
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/machines
[ 0:00] /dev/vda2        40G   34G  5.7G  86% /var/lib/mailman
[ 0:00] /dev/vda3        59G  108M   59G   1% /home
[ 0:00] tmpfs            98M   16K   98M   1% /run/user/478
[ 0:00] tmpfs            98M     0   98M   0% /run/user/0
[ 0:00] @TESTDIR=/tmp/LVMTEST10799.Ar4WzFQAt6
[ 0:00] @PREFIX=LVMTEST10799
[ 0:00] + test -f DEVICES
[ 0:00] + test prepare_lvmetad = dmsetup
[ 0:00] + prepare_lvmetad
[ 0:00] + check_daemon_in_builddir lvmetad
[ 0:00] + test -z ''
[ 0:00] + which lvmetad
[ 0:00] + grep -q /root/lvm2/test
[ 0:00] + rm -f debug.log strace.log
[ 0:00] + local run_valgrind=
[ 0:00] + test 0 -eq 0
[ 0:00] + kill_sleep_kill_ LOCAL_LVMETAD 0
[ 0:00] + local pidfile=LOCAL_LVMETAD
[ 0:00] + local slow=0
[ 0:00] + test -s LOCAL_LVMETAD
[ 0:00] + lvmconf 'global/use_lvmetad = 1' 'devices/md_component_detection = 0'
[ 0:00] + local profile_name=
[ 0:00] + test 2 -eq 0
[ 0:00] + local needed=0
[ 0:00] + for i in "$@"
[ 0:00] ++ grep global/use_lvmetad CONFIG_VALUES
[ 0:00] ++ tail -1
[ 0:00] + val=
[ 0:00] + needed=1
[ 0:00] + break
[ 0:00] + test 1 -eq 0
[ 0:00] + generate_config 'global/use_lvmetad = 1' 'devices/md_component_detection = 0'
[ 0:00] + test -n ''
[ 0:00] + config_values=CONFIG_VALUES
[ 0:00] + config=CONFIG
[ 0:00] + LVM_TEST_LOCKING=1
[ 0:00] + LVM_TEST_LVMETAD=1
[ 0:00] + LVM_TEST_LVMPOLLD=0
[ 0:00] + LVM_TEST_LVMLOCKD=0
[ 0:00] + test @TESTDIR@/dev = /dev
[ 0:00] + LVM_VERIFY_UDEV=1
[ 0:00] + test -f CONFIG_VALUES
[ 0:00] + cat
[ 0:00] + test -z varset
[ 0:00] + cat
[ 0:00] + local v
[ 0:00] + test 2 -gt 0
[ 0:00] + printf '%s\n' 'global/use_lvmetad = 1' 'devices/md_component_detection = 0'
[ 0:00] + declare -A CONF
[ 0:00] + local sec
[ 0:00] + local last_sec=
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='checks = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='monitoring = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='polling_interval = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='retry_deactivation = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='snapshot_autoextend_percent = 50'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='snapshot_autoextend_threshold = 50'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='udev_rules = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='udev_sync = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='verify_udev_operations = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='raid_region_size = 512'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='wipe_signatures_when_zeroing_new_lvs = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='archive = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='backup = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='cache_dir = "@TESTDIR@/etc"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='default_data_alignment = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='dir = "@TESTDIR@/dev"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='filter = "a|.*|"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='global_filter = [ "a|@TESTDIR@/dev/mapper/@PREFIX at .*pv[0-9_]*$|", "r|.*|" ]'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='md_component_detection  = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='scan = "@TESTDIR@/dev"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='sysfs_scan = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='write_cache_state = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='abort_on_internal_errors = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='cache_check_executable = "/usr/sbin/cache_check"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='cache_dump_executable = "/usr/sbin/cache_dump"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='cache_repair_executable = "/usr/sbin/cache_repair"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='detect_internal_vg_cache_corruption = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='fallback_to_local_locking = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='library_dir = "@TESTDIR@/lib"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='locking_dir = "@TESTDIR@/var/lock/lvm"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]=locking_type=1
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='notify_dbus = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='si_unit_consistency = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='thin_check_executable = "/usr/sbin/thin_check"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='thin_dump_executable = "/usr/sbin/thin_dump"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='thin_repair_executable = "/usr/sbin/thin_repair"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='use_lvmetad = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='use_lvmpolld = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='use_lvmlockd = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='activation = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='file = "@TESTDIR@/debug.log"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='indent = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='level = 9'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='overwrite = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='syslog = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='verbose = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='executable = "/root/lvm2/test/lib/dmeventd"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='fsadm_executable = "/root/lvm2/test/lib/fsadm"'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='use_lvmetad = 1'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + CONF["${v%%[={ ]*}"]='md_component_detection = 0'
[ 0:00] + IFS=
[ 0:00] + read -r v
[ 0:00] + printf '%s\n' global/abort_on_internal_errors global/cache_repair_executable global/detect_internal_vg_cache_corruption devices/filter devices/sysfs_scan log/indent log/file global/use_lvmpolld activation/raid_region_size activation/polling_interval log/verbose global/locking_type global/si_unit_consistency global/notify_dbus dmeventd/executable devices/default_data_alignment global/use_lvmetad log/level log/activation devices/global_filter devices/write_cache_state activation/snapshot_autoextend_percent backup/archive log/overwrite devices/cache_dir global/locking_dir allocation/wipe_signatures_when_zeroing_new_lvs activation/monitoring global/fsadm_executable global/cache_check_executable activation/verify_udev_operations global/library_dir devices/md_component_detection activation/snapshot_autoextend_threshold activation/checks activation/udev_rules devices/dir log/syslog global/thin_check_executable global/thin_dump_executable global/thin_repair_executable activation/udev_sync devices/scan activation/retry_deactivation global/fallback_to_local_locking backup/backup global/use_lvmlockd global/cache_dump_executable
[ 0:00] + read -r v
[ 0:00] + sort
[ 0:00] + sec=activation
[ 0:00] + test activation = ''
[ 0:00] + test -z ''
[ 0:00] + echo 'activation {'
[ 0:00] + last_sec=activation
[ 0:00] + echo '    checks = 1'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    monitoring = 0'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    polling_interval = 1'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    raid_region_size = 512'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    retry_deactivation = 1'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    snapshot_autoextend_percent = 50'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    snapshot_autoextend_threshold = 50'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    udev_rules = 1'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    udev_sync = 1'
[ 0:00] + read -r v
[ 0:00] + sec=activation
[ 0:00] + test activation = activation
[ 0:00] + echo '    verify_udev_operations = 1'
[ 0:00] + read -r v
[ 0:00] + sec=allocation
[ 0:00] + test allocation = activation
[ 0:00] + test -z activation
[ 0:00] + echo '}'
[ 0:00] + echo 'allocation {'
[ 0:00] + last_sec=allocation
[ 0:00] + echo '    wipe_signatures_when_zeroing_new_lvs = 0'
[ 0:00] + read -r v
[ 0:00] + sec=backup
[ 0:00] + test backup = allocation
[ 0:00] + test -z allocation
[ 0:00] + echo '}'
[ 0:00] + echo 'backup {'
[ 0:00] + last_sec=backup
[ 0:00] + echo '    archive = 0'
[ 0:00] + read -r v
[ 0:00] + sec=backup
[ 0:00] + test backup = backup
[ 0:00] + echo '    backup = 0'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = backup
[ 0:00] + test -z backup
[ 0:00] + echo '}'
[ 0:00] + echo 'devices {'
[ 0:00] + last_sec=devices
[ 0:00] + echo '    cache_dir = "@TESTDIR@/etc"'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    default_data_alignment = 1'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    dir = "@TESTDIR@/dev"'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    filter = "a|.*|"'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    global_filter = [ "a|@TESTDIR@/dev/mapper/@PREFIX at .*pv[0-9_]*$|", "r|.*|" ]'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    md_component_detection = 0'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    scan = "@TESTDIR@/dev"'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    sysfs_scan = 1'
[ 0:00] + read -r v
[ 0:00] + sec=devices
[ 0:00] + test devices = devices
[ 0:00] + echo '    write_cache_state = 0'
[ 0:00] + read -r v
[ 0:00] + sec=dmeventd
[ 0:00] + test dmeventd = devices
[ 0:00] + test -z devices
[ 0:00] + echo '}'
[ 0:00] + echo 'dmeventd {'
[ 0:00] + last_sec=dmeventd
[ 0:00] + echo '    executable = "/root/lvm2/test/lib/dmeventd"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = dmeventd
[ 0:00] + test -z dmeventd
[ 0:00] + echo '}'
[ 0:00] + echo 'global {'
[ 0:00] + last_sec=global
[ 0:00] + echo '    abort_on_internal_errors = 1'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    cache_check_executable = "/usr/sbin/cache_check"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    cache_dump_executable = "/usr/sbin/cache_dump"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    cache_repair_executable = "/usr/sbin/cache_repair"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    detect_internal_vg_cache_corruption = 1'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    fallback_to_local_locking = 0'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    fsadm_executable = "/root/lvm2/test/lib/fsadm"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    library_dir = "@TESTDIR@/lib"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    locking_dir = "@TESTDIR@/var/lock/lvm"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    locking_type=1'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    notify_dbus = 0'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    si_unit_consistency = 1'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    thin_check_executable = "/usr/sbin/thin_check"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    thin_dump_executable = "/usr/sbin/thin_dump"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    thin_repair_executable = "/usr/sbin/thin_repair"'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    use_lvmetad = 1'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    use_lvmlockd = 0'
[ 0:00] + read -r v
[ 0:00] + sec=global
[ 0:00] + test global = global
[ 0:00] + echo '    use_lvmpolld = 0'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = global
[ 0:00] + test -z global
[ 0:00] + echo '}'
[ 0:00] + echo 'log {'
[ 0:00] + last_sec=log
[ 0:00] + echo '    activation = 1'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    file = "@TESTDIR@/debug.log"'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    indent = 1'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    level = 9'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    overwrite = 1'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    syslog = 0'
[ 0:00] + read -r v
[ 0:00] + sec=log
[ 0:00] + test log = log
[ 0:00] + echo '    verbose = 0'
[ 0:00] + read -r v
[ 0:00] + echo '}'
[ 0:00] + sed -e 's,^,## LVMCONF: ,' CONFIG
[ 0:00] ## LVMCONF: activation {
[ 0:00] ## LVMCONF:     checks = 1
[ 0:00] ## LVMCONF:     monitoring = 0
[ 0:00] ## LVMCONF:     polling_interval = 1
[ 0:00] ## LVMCONF:     raid_region_size = 512
[ 0:00] ## LVMCONF:     retry_deactivation = 1
[ 0:00] ## LVMCONF:     snapshot_autoextend_percent = 50
[ 0:00] ## LVMCONF:     snapshot_autoextend_threshold = 50
[ 0:00] ## LVMCONF:     udev_rules = 1
[ 0:00] ## LVMCONF:     udev_sync = 1
[ 0:00] ## LVMCONF:     verify_udev_operations = 1
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: allocation {
[ 0:00] ## LVMCONF:     wipe_signatures_when_zeroing_new_lvs = 0
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: backup {
[ 0:00] ## LVMCONF:     archive = 0
[ 0:00] ## LVMCONF:     backup = 0
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: devices {
[ 0:00] ## LVMCONF:     cache_dir = "@TESTDIR@/etc"
[ 0:00] ## LVMCONF:     default_data_alignment = 1
[ 0:00] ## LVMCONF:     dir = "@TESTDIR@/dev"
[ 0:00] ## LVMCONF:     filter = "a|.*|"
[ 0:00] ## LVMCONF:     global_filter = [ "a|@TESTDIR@/dev/mapper/@PREFIX at .*pv[0-9_]*$|", "r|.*|" ]
[ 0:00] ## LVMCONF:     md_component_detection = 0
[ 0:00] ## LVMCONF:     scan = "@TESTDIR@/dev"
[ 0:00] ## LVMCONF:     sysfs_scan = 1
[ 0:00] ## LVMCONF:     write_cache_state = 0
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: dmeventd {
[ 0:00] ## LVMCONF:     executable = "/root/lvm2/test/lib/dmeventd"
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: global {
[ 0:00] ## LVMCONF:     abort_on_internal_errors = 1
[ 0:00] ## LVMCONF:     cache_check_executable = "/usr/sbin/cache_check"
[ 0:00] ## LVMCONF:     cache_dump_executable = "/usr/sbin/cache_dump"
[ 0:00] ## LVMCONF:     cache_repair_executable = "/usr/sbin/cache_repair"
[ 0:00] ## LVMCONF:     detect_internal_vg_cache_corruption = 1
[ 0:00] ## LVMCONF:     fallback_to_local_locking = 0
[ 0:00] ## LVMCONF:     fsadm_executable = "/root/lvm2/test/lib/fsadm"
[ 0:00] ## LVMCONF:     library_dir = "@TESTDIR@/lib"
[ 0:00] ## LVMCONF:     locking_dir = "@TESTDIR@/var/lock/lvm"
[ 0:00] ## LVMCONF:     locking_type=1
[ 0:00] ## LVMCONF:     notify_dbus = 0
[ 0:00] ## LVMCONF:     si_unit_consistency = 1
[ 0:00] ## LVMCONF:     thin_check_executable = "/usr/sbin/thin_check"
[ 0:00] ## LVMCONF:     thin_dump_executable = "/usr/sbin/thin_dump"
[ 0:00] ## LVMCONF:     thin_repair_executable = "/usr/sbin/thin_repair"
[ 0:00] ## LVMCONF:     use_lvmetad = 1
[ 0:00] ## LVMCONF:     use_lvmlockd = 0
[ 0:00] ## LVMCONF:     use_lvmpolld = 0
[ 0:00] ## LVMCONF: }
[ 0:00] ## LVMCONF: log {
[ 0:00] ## LVMCONF:     activation = 1
[ 0:00] ## LVMCONF:     file = "@TESTDIR@/debug.log"
[ 0:00] ## LVMCONF:     indent = 1
[ 0:00] ## LVMCONF:     level = 9
[ 0:00] ## LVMCONF:     overwrite = 1
[ 0:00] ## LVMCONF:     syslog = 0
[ 0:00] ## LVMCONF:     verbose = 0
[ 0:00] ## LVMCONF: }
[ 0:00] + mv -f CONFIG @TESTDIR@/etc/lvm.conf
[ 0:00] + echo -n '## preparing lvmetad...'
[ 0:00] ## preparing lvmetad...+ echo 10845
[ 0:00] + lvmetad -f -s @TESTDIR@/lvmetad.socket -l all
[ 0:00] + for i in {1..100}
[ 0:00] + test 1 -eq 100
[ 0:00] + test -e @TESTDIR@/lvmetad.socket
[ 0:00] + echo -n .
[ 0:00] .+ sleep .1
[ 0:00] [D] creating @TESTDIR@/lvmetad.socket
[ 0:00] initialised state: vgid_to_metadata = 0x559dd2792f80
[ 0:00] + for i in {1..100}
[ 0:00] + test 2 -eq 100
[ 0:00] + test -e @TESTDIR@/lvmetad.socket
[ 0:00] + break
[ 0:00] + echo ok
[ 0:00] ok
[ 0:00] <======== Processing test: "lvmetad-dump.sh" ========>
[ 0:00] 
[ 0:00] aux prepare_vg 2
[ 0:00] #lvmetad-dump.sh:19+ aux prepare_vg 2
[ 0:00] + test -f DEVICES
[ 0:00] + test prepare_vg = dmsetup
[ 0:00] + prepare_vg 2
[ 0:00] + teardown_devs
[ 0:00] + teardown_udev_cookies
[ 0:00] + test 1 = 1
[ 0:00] + dmsetup udevcomplete_all -y 10
[ 0:00] + grep -v '^0 '
[ 0:00] + true
[ 0:00] + test '!' -f MD_DEV
[ 0:00] + test '!' -f DEVICES
[ 0:00] + test -f SCSI_DEBUG_DEV
[ 0:00] + test '!' -f LOOP
[ 0:00] + test '!' -f LOOPFILE
[ 0:00] + not diff LOOP BACKING_DEV
[ 0:00] + rm -f DEVICES LOOP
[ 0:00] + test 0 -eq 1
[ 0:00] + test -z LVMTEST
[ 0:00] + stray_loops=($(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1))
[ 0:00] ++ losetup -a
[ 0:00] ++ grep LVMTEST
[ 0:00] ++ cut -d: -f1
[ 0:00] + local stray_loops
[ 0:00] + test 0 -eq 0
[ 0:00] + prepare_devs 2
[ 0:00] + local n=2
[ 0:00] + local devsize=34
[ 0:00] + local pvname=pv
[ 0:00] + local shift=0
[ 0:00] + test -n ''
[ 0:00] + touch DEVICES
[ 0:00] + prepare_backing_dev 68
[ 0:00] + test -f BACKING_DEV
[ 0:00] + test -b ''
[ 0:00] + prepare_loop 68
[ 0:00] + local size=68
[ 0:00] + shift
[ 0:00] + local i
[ 0:00] + local slash
[ 0:00] + test -f LOOP
[ 0:00] + echo -n '## preparing loop device...'
[ 0:00] ## preparing loop device...+ test -f SCSI_DEBUG_DEV -a -f LOOP
[ 0:00] + test '!' -e LOOP
[ 0:00] + test -n @TESTDIR@/dev
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop0
[ 0:00] + mknod @TESTDIR@/dev/loop0 b 7 0
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop1
[ 0:00] + mknod @TESTDIR@/dev/loop1 b 7 1
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop2
[ 0:00] + mknod @TESTDIR@/dev/loop2 b 7 2
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop3
[ 0:00] + mknod @TESTDIR@/dev/loop3 b 7 3
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop4
[ 0:00] + mknod @TESTDIR@/dev/loop4 b 7 4
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop5
[ 0:00] + mknod @TESTDIR@/dev/loop5 b 7 5
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop6
[ 0:00] + mknod @TESTDIR@/dev/loop6 b 7 6
[ 0:00] + for i in 0 1 2 3 4 5 6 7
[ 0:00] + test -e @TESTDIR@/dev/loop7
[ 0:00] + mknod @TESTDIR@/dev/loop7 b 7 7
[ 0:00] + echo -n .
[ 0:00] .+ local LOOPFILE=@TESTDIR@/test.img
[ 0:00] + rm -f @TESTDIR@/test.img
[ 0:00] + dd if=/dev/zero of=@TESTDIR@/test.img bs=1048576 count=0 seek=69
[ 0:00] ++ losetup -s -f @TESTDIR@/test.img
[ 0:00] + LOOP=
[ 0:00] ++ losetup -f
[ 0:00] + LOOP=/dev/loop0
[ 0:00] + losetup /dev/loop0 @TESTDIR@/test.img
[ 0:00] + :
[ 0:00] + test -n /dev/loop0
[ 0:00] + BACKING_DEV=/dev/loop0
[ 0:00] + echo /dev/loop0
[ 0:00] + echo /dev/loop0
[ 0:00] + echo 'ok (/dev/loop0)'
[ 0:00] ok (/dev/loop0)
[ 0:00] + not diff LOOP BACKING_DEV
[ 0:00] + shift=2048
[ 0:00] + echo -n '## preparing 2 devices...'
[ 0:00] ## preparing 2 devices...+ local size=69632
[ 0:00] + local count=0
[ 0:00] + rm -f CREATE_FAILED
[ 0:00] + init_udev_transaction
[ 0:00] + test 1 = 1
[ 0:00] + local cookie
[ 0:00] ++ dmsetup udevcreatecookie
[ 0:00] + cookie=0x0D4DD955
[ 0:00] + test -z 0x0D4DD955
[ 0:00] + export DM_UDEV_COOKIE=0x0D4DD955
[ 0:00] + DM_UDEV_COOKIE=0x0D4DD955
[ 0:00] ++ seq 1 2
[ 0:00] + for i in $(seq 1 "$n")
[ 0:00] + local name=@PREFIX at pv1
[ 0:00] + local dev=@TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:00] + DEVICES[$count]=@TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:00] + count=1
[ 0:00] + echo 0 69632 linear /dev/loop0 2048
[ 0:00] + test -f CREATE_FAILED
[ 0:00] + for i in $(seq 1 "$n")
[ 0:00] + local name=@PREFIX at pv2
[ 0:00] + local dev=@TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] + DEVICES[$count]=@TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] + count=2
[ 0:00] + echo 0 69632 linear /dev/loop0 71680
[ 0:00] + test -f CREATE_FAILED
[ 0:00] + wait
[ 0:00] + dmsetup create -u TEST- at PREFIX@pv2 @PREFIX at pv2 @PREFIX at pv2.table
[ 0:00] + dmsetup create -u TEST- at PREFIX@pv1 @PREFIX at pv1 @PREFIX at pv1.table
[ 0:00] + finish_udev_transaction
[ 0:00] + test 1 = 1
[ 0:00] + test -n 0x0D4DD955
[ 0:00] + dmsetup udevreleasecookie
[ 0:00] + unset DM_UDEV_COOKIE
[ 0:00] + test -f CREATE_FAILED -a -n ''
[ 0:00] + test -f LOOP
[ 0:00] + printf '%s\n' @TESTDIR@/dev/mapper/@PREFIX at pv1 @TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] + echo ok
[ 0:00] ok
[ 0:00] + test -e LOCAL_LVMETAD
[ 0:00] + for dev in "${DEVICES[@]}"
[ 0:00] + notify_lvmetad @TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:00] + test -e LOCAL_LVMETAD
[ 0:00] + LVM_LOG_FILE_EPOCH=
[ 0:00] + pvscan --cache @TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:00] <- request="hello"
[ 0:00] -> response = "OK"
[ 0:00] -> protocol = "lvmetad"
[ 0:00] -> version = 1
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] 10897 global info flags none reason none token none update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "none"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="token_update"
[ 0:00] <- token="update in progress"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] token_update begin 262010 timeout 10 pid 10897 cmd pvscan
[ 0:00] -> response = "OK"
[ 0:00] -> prev_token = ""
[ 0:00] -> update_pid = 10897
[ 0:00] -> 
[ 0:00] <- request="pv_clear_all"
[ 0:00] <- token="update in progress"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] pv_clear_all
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00] <- request="pv_gone"
[ 0:00] <- device=65026
[ 0:00] <- token="update in progress"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] pv_gone device 65026 not found
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "device not in cache"
[ 0:00] -> 
[ 0:00] <- request="pv_gone"
[ 0:00] <- device=65027
[ 0:00] <- token="update in progress"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] pv_gone device 65027 not found
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "device not in cache"
[ 0:00] -> 
[ 0:00] <- request="token_update"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] token_update end len 0 pid 10897 new token filter:1939810257
[ 0:00] -> response = "OK"
[ 0:00] -> prev_token = "update in progress"
[ 0:00] -> update_pid = 0
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] 10897 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10897
[ 0:00] <- cmd="pvscan"
[ 0:00] 10897 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] + rm -f debug.log
[ 0:00] + for dev in "${DEVICES[@]}"
[ 0:00] + notify_lvmetad @TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] + test -e LOCAL_LVMETAD
[ 0:00] + LVM_LOG_FILE_EPOCH=
[ 0:00] + pvscan --cache @TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] <- request="hello"
[ 0:00] -> response = "OK"
[ 0:00] -> protocol = "lvmetad"
[ 0:00] -> version = 1
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10901
[ 0:00] <- cmd="pvscan"
[ 0:00] 10901 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10901
[ 0:00] <- cmd="pvscan"
[ 0:00] 10901 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00]   No PV label found on @TESTDIR@/dev/mapper/@PREFIX at pv2.
[ 0:00] <- request="pv_gone"
[ 0:00] <- device=65026
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10901
[ 0:00] <- cmd="pvscan"
[ 0:00] pv_gone device 65026 not found
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "device not in cache"
[ 0:00] -> 
[ 0:00] + rm -f debug.log
[ 0:00] + vgcreate -s 512K @PREFIX at vg @TESTDIR@/dev/mapper/@PREFIX at pv1 @TESTDIR@/dev/mapper/@PREFIX at pv2
[ 0:00] <- request="hello"
[ 0:00] -> response = "OK"
[ 0:00] -> protocol = "lvmetad"
[ 0:00] -> version = 1
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] 10904 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] 10904 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="pv_list"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_list
[ 0:00] -> response="OK"
[ 0:00] -> physical_volumes {
[ 0:00] -> }
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] <- request="vg_lookup"
[ 0:00] <- name="@PREFIX at vg"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] vg_lookup vgid none name @PREFIX@vg needs lookup
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "VG not found"
[ 0:00] -> 
[ 0:00] <- request="vg_lookup"
[ 0:00] <- name="@PREFIX at vg"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] vg_lookup vgid none name @PREFIX@vg needs lookup
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "VG not found"
[ 0:00] -> 
[ 0:00] <- request="vg_lookup"
[ 0:00] <- name="@PREFIX at vg"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] vg_lookup vgid none name @PREFIX@vg needs lookup
[ 0:00] -> response = "unknown"
[ 0:00] -> reason = "VG not found"
[ 0:00] -> 
[ 0:00] <- request="vg_list"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] vg_list
[ 0:00] -> response="OK"
[ 0:00] -> volume_groups {
[ 0:00] -> }
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] <- request="pv_list"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_list
[ 0:00] -> response="OK"
[ 0:00] -> physical_volumes {
[ 0:00] -> }
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65027
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=0
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on device 65027 is new
[ 0:00] pv_found new entry device_to_pvid 65027 to qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on 65027 not in VG 
[ 0:00] -> response = "OK"
[ 0:00] -> status = "orphan"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "#orphan"
[ 0:00] -> vgname = "#orphan"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = -1
[ 0:00] -> 
[ 0:00]   Physical volume "@TESTDIR@/dev/mapper/@PREFIX at pv1" successfully created.
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65026
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=0
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on device 65026 is new
[ 0:00] pv_found new entry device_to_pvid 65026 to y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on 65026 not in VG 
[ 0:00] -> response = "OK"
[ 0:00] -> status = "orphan"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "#orphan"
[ 0:00] -> vgname = "#orphan"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = -1
[ 0:00] -> 
[ 0:00]   Physical volume "@TESTDIR@/dev/mapper/@PREFIX at pv2" successfully created.
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65027
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on device 65027 matches existing
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on 65027 not in VG 
[ 0:00] -> response = "OK"
[ 0:00] -> status = "orphan"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "#orphan"
[ 0:00] -> vgname = "#orphan"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = -1
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65026
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on device 65026 matches existing
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on 65026 not in VG 
[ 0:00] -> response = "OK"
[ 0:00] -> status = "orphan"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "#orphan"
[ 0:00] -> vgname = "#orphan"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = -1
[ 0:00] -> 
[ 0:00] <- request="set_vg_info"
[ 0:00] <- name="@PREFIX@vg"
[ 0:00] <- uuid="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- version=1
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00] <- request="vg_update"
[ 0:00] <- vgname="@PREFIX at vg"
[ 0:00] <- metadata {
[ 0:00] <- 	id="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- 	seqno=1
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	status=["RESIZEABLE","READ","WRITE"]
[ 0:00] <- 	flags=[]
[ 0:00] <- 	extent_size=1024
[ 0:00] <- 	max_lv=0
[ 0:00] <- 	max_pv=0
[ 0:00] <- 	metadata_copies=0
[ 0:00] <- 	physical_volumes {
[ 0:00] <- 		pv0 {
[ 0:00] <- 			id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 			device="@TESTDIR@/dev/mapper/@PREFIX at pv1"
[ 0:00] <- 			status="ALLOCATABLE"
[ 0:00] <- 			flags=[]
[ 0:00] <- 			dev_size=69632
[ 0:00] <- 			pe_start=2048
[ 0:00] <- 			pe_count=66
[ 0:00] <- 		}
[ 0:00] <- 		pv1 {
[ 0:00] <- 			id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 			device="@TESTDIR@/dev/mapper/@PREFIX at pv2"
[ 0:00] <- 			status="ALLOCATABLE"
[ 0:00] <- 			flags=[]
[ 0:00] <- 			dev_size=69632
[ 0:00] <- 			pe_start=2048
[ 0:00] <- 			pe_count=66
[ 0:00] <- 		}
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] vg_update vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg name @PREFIX at vg
[ 0:00] update_metadata begin arg_vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg arg_name @PREFIX at vg pvid none
[ 0:00] update_metadata new name @PREFIX at vg and new vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] update_metadata_add_new for @PREFIX at vg wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] moving PV qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 to VG wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] moving PV y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S to VG wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] update_metadata_add_new is done for @PREFIX@vg wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65027
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on device 65027 matches existing
[ 0:00] -> response = "OK"
[ 0:00] -> status = "complete"
[ 0:00] -> changed = 0
[ 0:00] -> vgid = "wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] -> vgname = "@PREFIX at vg"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = 1
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65026
[ 0:00] <- 	dev_size=35651584
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10904
[ 0:00] <- cmd="vgcreate"
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on device 65026 matches existing
[ 0:00] -> response = "OK"
[ 0:00] -> status = "complete"
[ 0:00] -> changed = 0
[ 0:00] -> vgid = "wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] -> vgname = "@PREFIX at vg"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = 1
[ 0:00] -> 
[ 0:00]   WARNING: This metadata update is NOT backed up.
[ 0:00]   Volume group "@PREFIX at vg" successfully created
[ 0:00] lvcreate -n bar -l 1 $vg
[ 0:00] #lvmetad-dump.sh:20+ lvcreate -n bar -l 1 @PREFIX at vg
[ 0:00] <- request="hello"
[ 0:00] -> response = "OK"
[ 0:00] -> protocol = "lvmetad"
[ 0:00] -> version = 1
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] 10906 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="get_global_info"
[ 0:00] <- token="skip"
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] 10906 global info flags none reason none token filter:1939810257 update_pid 0
[ 0:00] -> response = "OK"
[ 0:00] -> global_invalid = 0
[ 0:00] -> global_disable = 0
[ 0:00] -> disable_reason = "none"
[ 0:00] -> daemon_pid = 10845
[ 0:00] -> token = "filter:1939810257"
[ 0:00] -> update_cmd = ""
[ 0:00] -> update_pid = 0
[ 0:00] -> update_begin = 0
[ 0:00] -> update_timeout = 0
[ 0:00] -> 
[ 0:00] <- request="vg_list"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] vg_list
[ 0:00] -> response="OK"
[ 0:00] -> volume_groups {
[ 0:00] -> 	wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg {
[ 0:00] -> 		name="@PREFIX at vg"
[ 0:00] -> 	}
[ 0:00] -> }
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] <- request="vg_lookup"
[ 0:00] <- uuid="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- name="@PREFIX at vg"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] vg_lookup vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg name @PREFIX@vg
[ 0:00] -> response="OK"
[ 0:00] -> name="@PREFIX at vg"
[ 0:00] -> metadata {
[ 0:00] -> 	id="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] -> 	seqno=1
[ 0:00] -> 	format="lvm2"
[ 0:00] -> 	status=["RESIZEABLE","READ","WRITE"]
[ 0:00] -> 	flags=[]
[ 0:00] -> 	extent_size=1024
[ 0:00] -> 	max_lv=0
[ 0:00] -> 	max_pv=0
[ 0:00] -> 	metadata_copies=0
[ 0:00] -> 	physical_volumes {
[ 0:00] -> 		pv0 {
[ 0:00] -> 			device=65027
[ 0:00] -> 			format="lvm2"
[ 0:00] -> 			label_sector=1
[ 0:00] -> 			ext_version=2
[ 0:00] -> 			ext_flags=1
[ 0:00] -> 			mda0 {
[ 0:00] -> 				ignore=0
[ 0:00] -> 				start=4096
[ 0:00] -> 				size=1044480
[ 0:00] -> 				free_sectors=0
[ 0:00] -> 			}
[ 0:00] -> 			da0 {
[ 0:00] -> 				offset=1048576
[ 0:00] -> 				size=0
[ 0:00] -> 			}
[ 0:00] -> 			ba0 {
[ 0:00] -> 				offset=0
[ 0:00] -> 				size=0
[ 0:00] -> 			}
[ 0:00] -> 			id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] -> 			status="ALLOCATABLE"
[ 0:00] -> 			flags=[]
[ 0:00] -> 			dev_size=69632
[ 0:00] -> 			pe_start=2048
[ 0:00] -> 			pe_count=66
[ 0:00] -> 		}
[ 0:00] -> 		pv1 {
[ 0:00] -> 			device=65026
[ 0:00] -> 			format="lvm2"
[ 0:00] -> 			label_sector=1
[ 0:00] -> 			ext_version=2
[ 0:00] -> 			ext_flags=1
[ 0:00] -> 			mda0 {
[ 0:00] -> 				ignore=0
[ 0:00] -> 				start=4096
[ 0:00] -> 				size=1044480
[ 0:00] -> 				free_sectors=0
[ 0:00] -> 			}
[ 0:00] -> 			da0 {
[ 0:00] -> 				offset=1048576
[ 0:00] -> 				size=0
[ 0:00] -> 			}
[ 0:00] -> 			ba0 {
[ 0:00] -> 				offset=0
[ 0:00] -> 				size=0
[ 0:00] -> 			}
[ 0:00] -> 			id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] -> 			status="ALLOCATABLE"
[ 0:00] -> 			flags=[]
[ 0:00] -> 			dev_size=69632
[ 0:00] -> 			pe_start=2048
[ 0:00] -> 			pe_count=66
[ 0:00] -> 		}
[ 0:00] -> 	}
[ 0:00] -> }
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] -> 
[ 0:00] <- request="vg_clear_outdated_pvs"
[ 0:00] <- vgid="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] vg_clear_outdated_pvs vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00] <- request="set_vg_info"
[ 0:00] <- name="@PREFIX@vg"
[ 0:00] <- uuid="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- version=2
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] set info VG name none uuid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg cache_version 1 new_version 2
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00]   WARNING: This metadata update is NOT backed up.
[ 0:00]   The link @TESTDIR@/dev/@PREFIX at vg/bar should have been created by udev but it was not found. Falling back to direct link creation.
[ 0:00]   @TESTDIR@/dev/mapper/@PREFIX at vg-bar not set up by udev: Falling back to direct node creation.
[ 0:00]   Logical volume "bar" created.
[ 0:00] <- request="vg_update"
[ 0:00] <- vgname="@PREFIX at vg"
[ 0:00] <- metadata {
[ 0:00] <- 	id="wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] <- 	seqno=2
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	status=["RESIZEABLE","READ","WRITE"]
[ 0:00] <- 	flags=[]
[ 0:00] <- 	extent_size=1024
[ 0:00] <- 	max_lv=0
[ 0:00] <- 	max_pv=0
[ 0:00] <- 	metadata_copies=0
[ 0:00] <- 	physical_volumes {
[ 0:00] <- 		pv0 {
[ 0:00] <- 			id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 			device="@TESTDIR@/dev/mapper/@PREFIX at pv1"
[ 0:00] <- 			status="ALLOCATABLE"
[ 0:00] <- 			flags=[]
[ 0:00] <- 			dev_size=69632
[ 0:00] <- 			pe_start=2048
[ 0:00] <- 			pe_count=66
[ 0:00] <- 		}
[ 0:00] <- 		pv1 {
[ 0:00] <- 			id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 			device="@TESTDIR@/dev/mapper/@PREFIX at pv2"
[ 0:00] <- 			status="ALLOCATABLE"
[ 0:00] <- 			flags=[]
[ 0:00] <- 			dev_size=69632
[ 0:00] <- 			pe_start=2048
[ 0:00] <- 			pe_count=66
[ 0:00] <- 		}
[ 0:00] <- 	}
[ 0:00] <- 	logical_volumes {
[ 0:00] <- 		bar {
[ 0:00] <- 			id="ji8FVC-6cRg-3fK2-AVLQ-DVHx-tU4e-Qg1aZd"
[ 0:00] <- 			status=["READ","WRITE","VISIBLE"]
[ 0:00] <- 			flags=[]
[ 0:00] <- 			creation_time=1513263803
[ 0:00] <- 			creation_host="tw1"
[ 0:00] <- 			segment_count=1
[ 0:00] <- 			segment1 {
[ 0:00] <- 				start_extent=0
[ 0:00] <- 				extent_count=1
[ 0:00] <- 				type="striped"
[ 0:00] <- 				stripe_count=1
[ 0:00] <- 				stripes=["pv0",0]
[ 0:00] <- 			}
[ 0:00] <- 		}
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] vg_update vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg name @PREFIX at vg
[ 0:00] update_metadata begin arg_vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg arg_name @PREFIX at vg pvid none
[ 0:00] update_metadata existing vgid wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg and existing name @PREFIX at vg
[ 0:00] update_metadata for @PREFIX at vg wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg from 1 to 2
[ 0:00] moving PV qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 to VG #orphan
[ 0:00] moving PV y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S to VG #orphan
[ 0:00] moving PV qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 to VG wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] moving PV y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S to VG wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] update_metadata is done for @PREFIX@vg wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg
[ 0:00] -> response = "OK"
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65027
[ 0:00] <- 	dev_size=69632
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] pv_found pvid qixJkV-CSD1-CFsF-u9Fd-EwWL-cdgm-Uh2OO2 on device 65027 matches existing
[ 0:00] -> response = "OK"
[ 0:00] -> status = "complete"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] -> vgname = "@PREFIX at vg"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = 2
[ 0:00] -> 
[ 0:00] <- request="pv_found"
[ 0:00] <- pvmeta {
[ 0:00] <- 	device=65026
[ 0:00] <- 	dev_size=69632
[ 0:00] <- 	format="lvm2"
[ 0:00] <- 	label_sector=1
[ 0:00] <- 	id="y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S"
[ 0:00] <- 	ext_version=2
[ 0:00] <- 	ext_flags=1
[ 0:00] <- 	mda0 {
[ 0:00] <- 		ignore=0
[ 0:00] <- 		start=4096
[ 0:00] <- 		size=1044480
[ 0:00] <- 		free_sectors=0
[ 0:00] <- 	}
[ 0:00] <- 	da0 {
[ 0:00] <- 		offset=1048576
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- 	ba0 {
[ 0:00] <- 		offset=0
[ 0:00] <- 		size=0
[ 0:00] <- 	}
[ 0:00] <- }
[ 0:00] <- token="filter:1939810257"
[ 0:00] <- update_timeout=10
[ 0:00] <- pid=10906
[ 0:00] <- cmd="lvcreate"
[ 0:00] pv_found pvid y01sNE-hCt0-fNSA-qz5v-kgcf-HfiJ-heL91S on device 65026 matches existing
[ 0:00] -> response = "OK"
[ 0:00] -> status = "complete"
[ 0:00] -> changed = 1
[ 0:00] -> vgid = "wJ86F1-N8ce-oPzu-jLaG-YJ0i-45QT-HJqycg"
[ 0:00] -> vgname = "@PREFIX at vg"
[ 0:00] -> seqno_before = -1
[ 0:00] -> seqno_after = 2
[ 0:00] -> 
[ 0:00] 
[ 0:00] aux lvmetad_dump | tee lvmetad.txt
[ 0:00] #lvmetad-dump.sh:22+ aux lvmetad_dump
[ 0:00] #lvmetad-dump.sh:22+ tee lvmetad.txt
[ 0:00] + test -f DEVICES
[ 0:00] + devs='@TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:00] @TESTDIR@/dev/mapper/@PREFIX at pv2'
[ 0:00] + test lvmetad_dump = dmsetup
[ 0:00] + lvmetad_dump
[ 0:00] + echo 'request="dump"'
[ 0:00] + echo '##'
[ 0:00] + lvmetad_talk
[ 0:00] + local use=nc
[ 0:00] + type -p socat
[ 0:00] + echo
[ 0:00] + not nc -U @TESTDIR@/lvmetad.socket
[ 0:00] aux teardown
[ 0:28] ##lvmetad-dump.sh:1+ aux teardown
[ 0:28] + test -f DEVICES
[ 0:28] + devs='@TESTDIR@/dev/mapper/@PREFIX at pv1
[ 0:28] @TESTDIR@/dev/mapper/@PREFIX at pv2'
[ 0:28] + test teardown = dmsetup
[ 0:28] + teardown
[ 0:28] + local TEST_LEAKED_DEVICES=
[ 0:28] + echo -n '## teardown...'
[ 0:28] ## teardown...+ unset LVM_LOG_FILE_EPOCH
[ 0:28] + test -f TESTNAME
[ 0:28] + test '!' -f SKIP_THIS_TEST
[ 0:28] ++ dmsetup table
[ 0:28] ++ grep @PREFIX@
[ 0:28] ++ grep -v @PREFIX at pv
[ 0:28] + TEST_LEAKED_DEVICES='@PREFIX at vg-bar: 0 1024 linear 254:3 2048'
[ 0:28] + kill_tagged_processes
[ 0:28] + local pid
[ 0:28] + local wait
[ 0:28] + pids=()
[ 0:28] + local pids
[ 0:28] + read -r pid wait
[ 0:28] ++ print_procs_by_tag_
[ 0:28] ++ ps -o pid,args ehax
[ 0:28] ++ grep -weLVM_TEST_TAG=kill_me_ at PREFIX@
[ 0:28] ++ true
[ 0:28] + test 0 -eq 0
[ 0:28] + return
[ 0:28] + test -n ''
[ 0:28] + kill_sleep_kill_ LOCAL_LVMETAD 0
[ 0:28] + local pidfile=LOCAL_LVMETAD
[ 0:28] + local slow=0
[ 0:28] + test -s LOCAL_LVMETAD
[ 0:28] + pid=10845
[ 0:28] + rm -f LOCAL_LVMETAD
[ 0:28] + kill -TERM 10845
[ 0:28] + test 0 -eq 0
[ 0:28] + sleep .1
[ 0:28] I: lvmetad waiting for client threads to finish
[ 0:28] fini
[ 0:28] I: lvmetad shutting down
[ 0:28] + kill -KILL 10845
[ 0:29] + true
[ 0:29] + local wait=0
[ 0:29] + ps 10845
[ 0:29] + dm_table
[ 0:29] + should dmsetup table
[ 0:29] + not grep -E -q '@PREFIX at vg|@PREFIX at vg1|@PREFIX at vg2|@PREFIX at vg3|@PREFIX at vg4'
[ 0:29] ++ test -s LOCAL_DMEVENTD
[ 0:29] ++ echo '--config activation{monitoring=0}'
[ 0:29] + cfg='--config activation{monitoring=0}'
[ 0:29] + dm_info suspended,name
[ 0:29] + should dmsetup info --noheadings -c -o suspended,name
[ 0:29] + grep -q '^Suspended:.*@PREFIX@'
[ 0:29] + vgremove -ff '--config activation{monitoring=0}' @PREFIX at vg @PREFIX at vg1 @PREFIX at vg2 @PREFIX at vg3 @PREFIX at vg4
[ 0:29] + rm -f debug.log strace.log
[ 0:29] + kill_sleep_kill_ LOCAL_LVMDBUSD 0
[ 0:29] + local pidfile=LOCAL_LVMDBUSD
[ 0:29] + local slow=0
[ 0:29] + test -s LOCAL_LVMDBUSD
[ 0:29] + echo -n .
[ 0:29] .+ kill_sleep_kill_ LOCAL_LVMPOLLD 0
[ 0:29] + local pidfile=LOCAL_LVMPOLLD
[ 0:29] + local slow=0
[ 0:29] + test -s LOCAL_LVMPOLLD
[ 0:29] + echo -n .
[ 0:29] .+ kill_sleep_kill_ LOCAL_CLVMD 0
[ 0:29] + local pidfile=LOCAL_CLVMD
[ 0:29] + local slow=0
[ 0:29] + test -s LOCAL_CLVMD
[ 0:29] + echo -n .
[ 0:29] .+ kill_sleep_kill_ LOCAL_DMEVENTD 0
[ 0:29] + local pidfile=LOCAL_DMEVENTD
[ 0:29] + local slow=0
[ 0:29] + test -s LOCAL_DMEVENTD
[ 0:29] + echo -n .
[ 0:29] .+ test -d @TESTDIR@/dev/mapper
[ 0:29] + teardown_devs
[ 0:29] + teardown_udev_cookies
[ 0:29] + test 1 = 1
[ 0:29] + grep -v '^0 '
[ 0:29] + dmsetup udevcomplete_all -y 10
[ 0:29] + true
[ 0:29] + test '!' -f MD_DEV
[ 0:29] + test '!' -f DEVICES
[ 0:29] + teardown_devs_prefixed @PREFIX@
[ 0:29] + local prefix=@PREFIX@
[ 0:29] + local stray=0
[ 0:29] + local 'IFS=
[ 0:29] '
[ 0:29] + local dm
[ 0:29] + rm -rf '@TESTDIR@/dev/@PREFIX@*'
[ 0:29] ++ dm_info suspended,name
[ 0:29] ++ grep '^Suspended:.*@PREFIX@'
[ 0:29] ++ should dmsetup info --noheadings -c -o suspended,name
[ 0:29] + wait
[ 0:29] + mounts=($(grep "$prefix" /proc/mounts | cut -d' ' -f1))
[ 0:29] ++ grep @PREFIX@ /proc/mounts
[ 0:29] ++ cut '-d ' -f1
[ 0:29] + local mounts
[ 0:29] + test 0 -gt 0
[ 0:29] + rm -f REMOVE_FAILED
[ 0:29] + for i in 0 1
[ 0:29] + local num_remaining_devs=999999
[ 0:29] + local num_devs=0
[ 0:29] + test 0 = 1
[ 0:29] + :
[ 0:29] + local cnt
[ 0:29] + local sortby=name
[ 0:29] + local need_udev_wait=0
[ 0:29] + test 0 = 0
[ 0:29] + dm_info name,open --separator ' ' --sort open,name
[ 0:29] + should dmsetup info --noheadings -c -o name,open --separator ' ' --sort open,name
[ 0:29] + grep @PREFIX@
[ 0:29] ++ wc -l
[ 0:29] + num_devs=3
[ 0:29] + test 3 -lt 999999
[ 0:29] + test 0 = 0
[ 0:29] + IFS=' '
[ 0:29] + read -r dm cnt
[ 0:29] + test 0 = 0
[ 0:29] + test 0 -eq 0
[ 0:29] + need_udev_wait=1
[ 0:29] + IFS=' '
[ 0:29] + read -r dm cnt
[ 0:29] + dmsetup remove @PREFIX at pv2
[ 0:29] + test 0 = 0
[ 0:29] + test 0 -eq 0
[ 0:29] + need_udev_wait=1
[ 0:29] + IFS=' '
[ 0:29] + read -r dm cnt
[ 0:29] + dmsetup remove @PREFIX at vg-bar
[ 0:29] + test 0 = 0
[ 0:29] + test 1 -eq 0
[ 0:29] + break
[ 0:29] + test 1 -eq 1
[ 0:29] + udev_wait
[ 0:29] + pgrep udev
[ 0:29] + which udevadm
[ 0:29] + test -n ''
[ 0:29] + udevadm settle --timeout=15
[ 0:29] + wait
[ 0:29] + num_remaining_devs=3
[ 0:29] + :
[ 0:29] + local cnt
[ 0:29] + local sortby=name
[ 0:29] + local need_udev_wait=0
[ 0:29] + test 0 = 0
[ 0:29] + grep @PREFIX@
[ 0:29] + dm_info name,open --separator ' ' --sort open,name
[ 0:29] + should dmsetup info --noheadings -c -o name,open --separator ' ' --sort open,name
[ 0:29] ++ wc -l
[ 0:29] + num_devs=1
[ 0:29] + test 1 -lt 3
[ 0:29] + test 0 = 0
[ 0:29] + IFS=' '
[ 0:29] + read -r dm cnt
[ 0:29] + test 0 = 0
[ 0:29] + test 0 -eq 0
[ 0:29] + need_udev_wait=1
[ 0:29] + IFS=' '
[ 0:29] + read -r dm cnt
[ 0:29] + dmsetup remove @PREFIX at pv1
[ 0:29] + test 1 -eq 1
[ 0:29] + udev_wait
[ 0:29] + pgrep udev
[ 0:29] + which udevadm
[ 0:29] + test -n ''
[ 0:29] + udevadm settle --timeout=15
[ 0:29] + wait
[ 0:29] + num_remaining_devs=1
[ 0:29] + :
[ 0:29] + local cnt
[ 0:29] + local sortby=name
[ 0:29] + local need_udev_wait=0
[ 0:29] + test 0 = 0
[ 0:29] + dm_info name,open --separator ' ' --sort open,name
[ 0:29] + should dmsetup info --noheadings -c -o name,open --separator ' ' --sort open,name
[ 0:29] + grep @PREFIX@
[ 0:29] + break 2
[ 0:29] + test -f SCSI_DEBUG_DEV
[ 0:29] + test '!' -f LOOP
[ 0:29] + losetup -d /dev/loop0
[ 0:29] + test '!' -f LOOPFILE
[ 0:29] + not diff LOOP BACKING_DEV
[ 0:29] + rm -f BACKING_DEV
[ 0:29] + rm -f DEVICES LOOP
[ 0:29] + test 0 -eq 1
[ 0:29] + test -z LVMTEST
[ 0:29] + stray_loops=($(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1))
[ 0:29] ++ losetup -a
[ 0:29] ++ grep LVMTEST
[ 0:29] ++ cut -d: -f1
[ 0:29] + local stray_loops
[ 0:29] + test 0 -eq 0
[ 0:29] + echo -n .
[ 0:29] .+ test -z '@PREFIX at vg-bar: 0 1024 linear 254:3 2048'
[ 0:29] + echo '## unexpected devices left dm table:'
[ 0:29] ## unexpected devices left dm table:
[ 0:29] + echo '@PREFIX at vg-bar: 0 1024 linear 254:3 2048'
[ 0:29] @PREFIX at vg-bar: 0 1024 linear 254:3 2048
[ 0:29] + return 1
[ 0:29] set +vx; STACKTRACE; set -vx
[ 0:29] ###lvmetad-dump.sh:1+ set +vx
[ 0:29] ## - /root/lvm2/test/shell/lvmetad-dump.sh:1
[ 0:29] ## 1 STACKTRACE() called from /root/lvm2/test/shell/lvmetad-dump.sh:1
[ 0:29] <======== Script file "lvmetad-dump.sh" ========>
[ 0:29] ## Line: 1 	 #!/usr/bin/env bash
[ 0:29] ## Line: 2 	 
[ 0:29] ## Line: 3 	 # Copyright (C) 2012 Red Hat, Inc. All rights reserved.
[ 0:29] ## Line: 4 	 #
[ 0:29] ## Line: 5 	 # This copyrighted material is made available to anyone wishing to use,
[ 0:29] ## Line: 6 	 # modify, copy, or redistribute it subject to the terms and conditions
[ 0:29] ## Line: 7 	 # of the GNU General Public License v.2.
[ 0:29] ## Line: 8 	 #
[ 0:29] ## Line: 9 	 # You should have received a copy of the GNU General Public License
[ 0:29] ## Line: 10 	 # along with this program; if not, write to the Free Software Foundation,
[ 0:29] ## Line: 11 	 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
[ 0:29] ## Line: 12 	 
[ 0:29] ## Line: 13 	 SKIP_WITH_LVMLOCKD=1
[ 0:29] ## Line: 14 	 SKIP_WITHOUT_LVMETAD=1
[ 0:29] ## Line: 15 	 SKIP_WITH_LVMPOLLD=1
[ 0:29] ## Line: 16 	 
[ 0:29] ## Line: 17 	 . lib/inittest
[ 0:29] ## Line: 18 	 
[ 0:29] ## Line: 19 	 aux prepare_vg 2
[ 0:29] ## Line: 20 	 lvcreate -n bar -l 1 $vg
[ 0:29] ## Line: 21 	 
[ 0:29] ## Line: 22 	 aux lvmetad_dump | tee lvmetad.txt
[ 0:29] ## Line: 23 	 
[ 0:29] ## Line: 24 	 grep $vg lvmetad.txt
[ 0:29] ## Line: 25 	 
[ 0:29] ## Line: 26 	 vgremove -ff $vg
###  interrupted: [ndev-lvmetad] shell/lvmetad-dump.sh

### 1 tests: 0 passed, 0 skipped, 0 timed out, 0 warned, 0 failed
make: *** [Makefile:144: check_lvmetad] Error 1
