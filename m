From: Leo Yan <leo.yan@linaro.org>
Date: Thu,  3 Jun 2021 17:59:08 +0800
Subject: [PATCH v1 00/17] LVM2: Enable testing for In-Drive-Mutex
Message-ID: <20210603095925.510302-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch series is to enable In-Drive-Mutex (IDM) testing in LVM2.

Patches 01 ~ 04 are fundamental changes for supporting IDM testing.

  - Patch 01 provides the scripts for setting up environment and
    teardown.  And introduces the testing option for IDM;
  - Patch 02 is to extend backing device from only one device name to
    multiple device names with comma as splitter.  This can give the
    flexibility for testing IDM drives;
  - Patch 03 introduces the SCSI command to explicitly cleanup drive
    firmware;
  - Patch 04 adds checkers for lvmlockd log, it provides helper for
    verify the failure handling.

Patches 05 ~ 07 are stress testing patches, they verify the single
thread and multi-threads testing cases; this can give the pressure to
lvmlockd and the locking manager for multiple requests simultaneously.

Patches 08 ~ 13 are failure handling testing cases.  Patch 08 introduces
an utility for injection failures into the IDM lock manager, thus this
can emulate the drive failures in the lock manager; patch 09 is verify
the failure happens in lvmlockd; patches 10~12 test the failure
handling, which deliberately delete part or all drives, then check if
the IDM lock manager and lvmlockd can handle these failures as expected
or not; patch 13 is to check the failure handling when the IDM lock
manager is malfunctioning.

Patches 14 ~ 17 introduces multi-hosts testing cases.  Every testing
provides pair script, one is with suffix "hosta.sh" and another is with
suffix "hostb.sh".  The designed sequence is firstly to launch the
script "hosta.sh" on one host, and then run the script "hostb.sh" on
another host.  So with the co-operation with these two scripts, we can
verify the locking scheme on multi-hosts.

After applied this patch series, the IDM locking scheme was verified
on Centos 7 (centos-release-7-9.2009.1.el7.centos.x86_64) with commands:

  # export IDM_DRIVES=/dev/sdb2,/dev/sdd2,/dev/sde2,/dev/sdg2,\
         	     /dev/sdb3,/dev/sdd3,/dev/sde3,/dev/sdg3,\
         	     /dev/sdb4,/dev/sdd4,/dev/sde4,/dev/sdg4,\
         	     /dev/sdb5,/dev/sdd5,/dev/sde5,/dev/sdg5
  # make check_lvmlockd_idm LVM_TEST_BACKING_DEVICE=$IDM_DRIVES

The enviornment variable "IDM_DRIVES" is set to the partitions used for
PVs and the drives containing these partitions support IDM locking.

The testing result is recorded in the file [1]:
- The testing result shows no regression introduced for LVM core paths;
- There have 15 failure cases for IDM locking scheme, the main reasons
  for these failure cases are:
  1. Cannot find drive path cannot achieve majority for IDM locking
     algorithm;
  2. Have no sufficient disk size for the testing case;
  3. Fail to find drive device name after deleting PV's device mapper;
  4. Need to specify the bigger log line number, otherwise the testing
     is interrupted by the log system.

[1] https://github.com/Seagate/propeller/blob/master/doc/lvm_test.md


Leo Yan (17):
  tests: Enable the testing for IDM locking scheme
  tests: Support multiple backing devices
  tests: Cleanup idm context when prepare devices
  tests: Add checking for lvmlockd log
  tests: stress: Add single thread stress testing
  tests: stress: Add multi-threads stress testing for VG/LV
  tests: stress: Add multi-threads stress testing for PV/VG/LV
  tests: Support idm failure injection
  tests: Add testing for lvmlockd failure
  tests: idm: Add testing for the fabric failure
  tests: idm: Add testing for the fabric failure and timeout
  tests: idm: Add testing for the fabric's half brain failure
  tests: idm: Add testing for IDM lock manager failure
  tests: multi-hosts: Add VG testing
  tests: multi-hosts: Add LV testing
  tests: multi-hosts: Test lease timeout with LV exclusive mode
  tests: multi-hosts: Test lease timeout with LV shareable mode

 test/Makefile.in                              |  15 +++
 test/lib/aux.sh                               |  73 +++++++++++-
 test/lib/check.sh                             |   5 +
 test/lib/flavour-udev-lvmlockd-idm.sh         |   5 +
 test/lib/idm_inject_failure.c                 |  55 +++++++++
 test/lib/inittest.sh                          |   8 +-
 test/shell/aa-lvmlockd-idm-prepare.sh         |  20 ++++
 test/shell/idm_fabric_failure.sh              |  58 +++++++++
 test/shell/idm_fabric_failure_half_brain.sh   |  78 ++++++++++++
 test/shell/idm_fabric_failure_timeout.sh      |  74 ++++++++++++
 test/shell/idm_ilm_failure.sh                 |  80 +++++++++++++
 test/shell/lvmlockd-lv-types.sh               |   6 +
 test/shell/lvmlockd_failure.sh                |  37 ++++++
 test/shell/multi_hosts_lv_ex_timeout_hosta.sh |  87 ++++++++++++++
 test/shell/multi_hosts_lv_ex_timeout_hostb.sh |  56 +++++++++
 test/shell/multi_hosts_lv_hosta.sh            |  78 ++++++++++++
 test/shell/multi_hosts_lv_hostb.sh            |  61 ++++++++++
 test/shell/multi_hosts_lv_sh_timeout_hosta.sh |  87 ++++++++++++++
 test/shell/multi_hosts_lv_sh_timeout_hostb.sh |  56 +++++++++
 test/shell/multi_hosts_vg_hosta.sh            |  45 +++++++
 test/shell/multi_hosts_vg_hostb.sh            |  52 ++++++++
 test/shell/stress_multi_threads_1.sh          | 111 ++++++++++++++++++
 test/shell/stress_multi_threads_2.sh          |  93 +++++++++++++++
 test/shell/stress_single_thread.sh            |  59 ++++++++++
 test/shell/zz-lvmlockd-idm-remove.sh          |  29 +++++
 25 files changed, 1323 insertions(+), 5 deletions(-)
 create mode 100644 test/lib/flavour-udev-lvmlockd-idm.sh
 create mode 100644 test/lib/idm_inject_failure.c
 create mode 100644 test/shell/aa-lvmlockd-idm-prepare.sh
 create mode 100644 test/shell/idm_fabric_failure.sh
 create mode 100644 test/shell/idm_fabric_failure_half_brain.sh
 create mode 100644 test/shell/idm_fabric_failure_timeout.sh
 create mode 100644 test/shell/idm_ilm_failure.sh
 create mode 100644 test/shell/lvmlockd_failure.sh
 create mode 100644 test/shell/multi_hosts_lv_ex_timeout_hosta.sh
 create mode 100644 test/shell/multi_hosts_lv_ex_timeout_hostb.sh
 create mode 100644 test/shell/multi_hosts_lv_hosta.sh
 create mode 100644 test/shell/multi_hosts_lv_hostb.sh
 create mode 100644 test/shell/multi_hosts_lv_sh_timeout_hosta.sh
 create mode 100644 test/shell/multi_hosts_lv_sh_timeout_hostb.sh
 create mode 100644 test/shell/multi_hosts_vg_hosta.sh
 create mode 100644 test/shell/multi_hosts_vg_hostb.sh
 create mode 100644 test/shell/stress_multi_threads_1.sh
 create mode 100644 test/shell/stress_multi_threads_2.sh
 create mode 100644 test/shell/stress_single_thread.sh
 create mode 100644 test/shell/zz-lvmlockd-idm-remove.sh

-- 
2.25.1


