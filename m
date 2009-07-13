From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 13 Jul 2009 18:22:46 -0400 (EDT)
Subject: WARNING: dev_open(/dev/mapper/loop2) called while suspended
Message-ID: <Pine.LNX.4.64.0907131807050.494@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

With current LVM I'm getting this warning

WARNING: dev_open(/dev/mapper/loop2) called while suspended

(/dev/mapper/loop2 is one of four underlying PV devices)

The vg contains three volumes, a mirror, snapshot and origin.
LV    VG   Attr   LSize  Origin Snap%  Move Log      Copy%  Convert
lv1   vg1  mwi-a- 56.00M                    lv1_mlog 100.00
lv2   vg1  owi-a- 64.00M
lvol0 vg1  swi-a- 16.00M lv2      0.10

The warning happens if the mirror is active, the origin and snapshot is 
inactive and the user activates the origin with lvchange -ay vg1/lv2 
command. If the mirror is not active, the warning doesn't happen.

2.02.47 doesn't have this bug. 2.02.48 and current cvs does.

In the attachments there are outputs of lvchange -vvvv -ay vg1/lv2 and gdb 
backtrace.

So you may still consider trying to fix it before the release...

Mikulas
-------------- next part --------------
WARNING: dev_open(/dev/mapper/loop2) called while suspended

Breakpoint 2, dev_open_flags (dev=0xc6ad0, flags=2, direct=1, quiet=0)
    at device/dev-io.c:395
395                     log_error("WARNING: dev_open(%s) called while suspended",
(gdb) bt
#0  dev_open_flags (dev=0xc6ad0, flags=2, direct=1, quiet=0)
    at device/dev-io.c:395
#1  0x000486d0 in dev_open (dev=0xc6ad0) at device/dev-io.c:506
#2  0x00048928 in dev_get_read_ahead (dev=0xc6ad0, read_ahead=0xffb71c44)
    at device/dev-io.c:274
#3  0x00067860 in _lv_read_ahead_single (lv=0xf8f88, data=0xffb71f04)
    at metadata/metadata.c:1543
#4  0x000663ac in _lv_postorder_visit (lv=0xf8f88,
    fn=0x6780c <_lv_read_ahead_single>, data=0xffb71f04)
    at metadata/metadata.c:1451
#5  0x000663e8 in _lv_postorder_level (lv=0xf8f88, data=0xffb71e18)
    at metadata/metadata.c:1394
#6  0x00066208 in _lv_each_dependency (lv=0xf8f88,
    fn=0x663b4 <_lv_postorder_level>, data=0xffb71e18)
    at metadata/metadata.c:1411
#7  0x00066394 in _lv_postorder_visit (lv=0xf8f88,
    fn=0x6780c <_lv_read_ahead_single>, data=0xffb71f04)
    at metadata/metadata.c:1449
#8  0x0006658c in _lv_postorder (lv=0xf8f88,
    fn=0x6780c <_lv_read_ahead_single>, data=0xffb71f04)
    at metadata/metadata.c:1468
#9  0x00066668 in lv_calculate_readahead (lv=0xf8f88, read_ahead=0xffb71fac)
    at metadata/metadata.c:1561
#10 0x00078a38 in _add_new_lv_to_dtree (dm=0xfc9e8, dtree=0xe08a8, lv=0xf8f88,
---Type <return> to continue, or q <return> to quit---
    layer=0x97378 "cow") at activate/dev_manager.c:1024
#11 0x0007852c in _add_new_lv_to_dtree (dm=0xfc9e8, dtree=0xe08a8, lv=0xf8f88,
    layer=0x0) at activate/dev_manager.c:931
#12 0x00078940 in _add_new_lv_to_dtree (dm=0xfc9e8, dtree=0xe08a8, lv=0xf8ec8,
    layer=0x0) at activate/dev_manager.c:954
#13 0x000794c0 in _tree_action (dm=0xfc9e8, lv=0xf8ec8, action=ACTIVATE)
    at activate/dev_manager.c:1184
#14 0x000798ac in dev_manager_activate (dm=0xfc9e8, lv=0xf8ec8)
    at activate/dev_manager.c:1218
#15 0x0003b268 in _lv_activate_lv (lv=0xf8ec8) at activate/activate.c:585
#16 0x0003b924 in _lv_activate (cmd=0xb8028, lvid_s=<value optimized out>,
    exclusive=1, filter=1) at activate/activate.c:1101
#17 0x0003b9a0 in lv_activate_with_filter (cmd=0xb8028,
    lvid_s=0xffb73648 "VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO", exclusive=1) at activate/activate.c:1124
#18 0x0007d738 in _file_lock_resource (cmd=0xb8028,
    resource=0xffb73648 "VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO", flags=<value optimized out>) at locking/file_locking.c:258
#19 0x0005da40 in _lock_vol (cmd=0xb8028,
    resource=0xffb73648 "VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO", flags=61) at locking/locking.c:349
#20 0x0005ddb8 in lock_vol (cmd=0xb8028,
    vol=0xe4e30 "VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO", flags=61) at locking/locking.c:401
---Type <return> to continue, or q <return> to quit---
#21 0x0001d708 in lvchange_single (cmd=0xb8028, lv=0xe4e30, handle=0x0)
    at lvchange.c:131
#22 0x00032100 in process_each_lv_in_vg (cmd=0xb8028,
    vg=<value optimized out>, arg_lvnames=0xffb738f8, tags=0xffb73900,
    handle=0x0, process_single=0x1c3a4 <lvchange_single>) at toollib.c:150
#23 0x000331e8 in process_each_lv (cmd=0xb8028, argc=856555, argv=0x3,
    flags=1048576, handle=0x0, process_single=0x1c3a4 <lvchange_single>)
    at toollib.c:323
#24 0x0001b954 in lvchange (cmd=0xb8028, argc=1, argv=0xffb73d00)
    at lvchange.c:729
#25 0x00024950 in lvm_run_command (cmd=0xb8028, argc=1, argv=0xffb73d00)
    at lvmcmdline.c:1025
#26 0x00026c34 in lvm2_main (argc=3, argv=0xffb73cf8) at lvmcmdline.c:1361
#27 0x0003a878 in main (argc=4, argv=0xffb73cf4) at lvm.c:21

-------------- next part --------------
#lvmcmdline.c:1004         Processing: lvchange -vvvv -ay vg1/lv2
#lvmcmdline.c:1007         O_DIRECT will be used
#config/config.c:952       Setting global/locking_type to 1
#locking/locking.c:230       File-based locking selected.
#config/config.c:929       Setting global/locking_dir to /var/lock/lvm
#toollib.c:193     Using logical volume(s) on command line
#locking/file_locking.c:164       Locking /var/lock/lvm/V_vg1 WB
#device/dev-io.c:486         Opened /dev/mapper/loop1 RW O_DIRECT
#device/dev-io.c:134         /dev/mapper/loop1: block size is 8192 bytes
#label/label.c:160       /dev/mapper/loop1: lvm2 label detected
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop1: now in VG #orphans_lvm2 (#orphans_lvm2)
#device/dev-io.c:532         Closed /dev/mapper/loop1
#device/dev-io.c:486         Opened /dev/mapper/loop2 RW O_DIRECT
#device/dev-io.c:134         /dev/mapper/loop2: block size is 8192 bytes
#label/label.c:160       /dev/mapper/loop2: lvm2 label detected
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop2: now in VG #orphans_lvm2 (#orphans_lvm2)
#device/dev-io.c:532         Closed /dev/mapper/loop2
#device/dev-io.c:486         Opened /dev/mapper/loop3 RW O_DIRECT
#device/dev-io.c:134         /dev/mapper/loop3: block size is 8192 bytes
#label/label.c:160       /dev/mapper/loop3: lvm2 label detected
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop3: now in VG #orphans_lvm2 (#orphans_lvm2)
#device/dev-io.c:532         Closed /dev/mapper/loop3
#device/dev-io.c:486         Opened /dev/mapper/loop4 RW O_DIRECT
#device/dev-io.c:134         /dev/mapper/loop4: block size is 8192 bytes
#label/label.c:160       /dev/mapper/loop4: lvm2 label detected
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop4: now in VG #orphans_lvm2 (#orphans_lvm2)
#format_text/format-text.c:1121         /dev/mapper/loop4: Found metadata at 43520 size 3016 (in area at 8192 size 188416) for vg1 (VOPJIM-gCzp-0x7r-0a2Y-i8O2-xLd8-mteXYR)
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop4: now in VG vg1 with 1 mdas
#cache/lvmcache.c:772         lvmcache: /dev/mapper/loop4: setting vg1 VGID to VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYR
#cache/lvmcache.c:1022         lvmcache: /dev/mapper/loop4: VG vg1: Set creation host to slunicko.
#label/label.c:270         Using cached label for /dev/mapper/loop4
#label/label.c:270         Using cached label for /dev/mapper/loop1
#label/label.c:270         Using cached label for /dev/mapper/loop2
#label/label.c:270         Using cached label for /dev/mapper/loop3
#label/label.c:270         Using cached label for /dev/mapper/loop4
#metadata/lv_manip.c:338       Stack lv1:0[0] on LV lv1_mimage_0:0
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mimage_0
#metadata/lv_manip.c:338       Stack lv1:0[1] on LV lv1_mimage_1:0
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mimage_1
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mlog
#format_text/format-text.c:485         Read vg1 metadata (591) from /dev/mapper/loop4 at 43520 size 3016
#metadata/metadata.c:2071         Updating cache for PVs without mdas in VG vg1.
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop1: now in VG vg1 (VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYR) with 0 mdas
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop2: now in VG vg1 (VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYR) with 0 mdas
#cache/lvmcache.c:985         lvmcache: /dev/mapper/loop3: now in VG vg1 (VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYR) with 0 mdas
#cache/lvmcache.c:105         Metadata cache: VG vg1 (VOPJIM-gCzp-0x7r-0a2Y-i8O2-xLd8-mteXYR) stored (3016 bytes).
#cache/lvmcache.c:71         Metadata cache: VG vg1 wiped.
#cache/lvmcache.c:105         Metadata cache: VG vg1 (VOPJIM-gCzp-0x7r-0a2Y-i8O2-xLd8-mteXYR) stored (3016 bytes).
#metadata/pv_manip.c:272         /dev/mapper/loop1 0:      0     15: lv2(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 0:      0      1: lv2(15:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 1:      1      1: lv1_mlog(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 2:      2      4: lvol0(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 3:      6      9: NULL(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop3 0:      0     14: lv1_mimage_0(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop3 1:     14      1: NULL(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop4 0:      0     14: lv1_mimage_1(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop4 1:     14      1: NULL(0:0)
#lvchange.c:130     Activating logical volume "lv2" exclusively
#locking/file_locking.c:257       Locking LV VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO (EX)
#metadata/metadata.c:2370       Finding volume group for uuid VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO
#label/label.c:270         Using cached label for /dev/mapper/loop1
#label/label.c:270         Using cached label for /dev/mapper/loop2
#label/label.c:270         Using cached label for /dev/mapper/loop3
#label/label.c:270         Using cached label for /dev/mapper/loop4
#metadata/lv_manip.c:338       Stack lv1:0[0] on LV lv1_mimage_0:0
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mimage_0
#metadata/lv_manip.c:338       Stack lv1:0[1] on LV lv1_mimage_1:0
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mimage_1
#metadata/lv_manip.c:47       Adding lv1:0 as an user of lv1_mlog
#metadata/pv_manip.c:272         /dev/mapper/loop1 0:      0     15: lv2(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 0:      0      1: lv2(15:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 1:      1      1: lv1_mlog(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 2:      2      4: lvol0(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop2 3:      6      9: NULL(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop3 0:      0     14: lv1_mimage_0(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop3 1:     14      1: NULL(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop4 0:      0     14: lv1_mimage_1(0:0)
#metadata/pv_manip.c:272         /dev/mapper/loop4 1:     14      1: NULL(0:0)
#cache/lvmcache.c:530         Using cached metadata for VG vg1.
#metadata/metadata.c:2376     Found volume group "vg1"
#activate/activate.c:454         Getting device info for vg1-lv2
#ioctl/libdm-iface.c:1673         dm version   OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO NF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO NF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2  NF   [16384]
#device/dev-io.c:486         Opened /dev/mapper/loop1 RW O_DIRECT
#device/dev-io.c:291       /dev/mapper/loop1: read_ahead is 256 sectors
#mm/memlock.c:99       Locking memory
#mm/memlock.c:130         memlock_count inc to 1
#activate/dev_manager.c:631         Getting device info for vg1-lv2 [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2-real [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2-real  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2-cow [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2-cow  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2_mlog [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2_mlog  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0 [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4 OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4 OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0-real [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0-real  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0-cow [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0-cow  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0_mlog [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0_mlog  OF   [16384]
#activate/dev_manager.c:907         Checking kernel supports striped segment type for lv2
#activate/activate.c:363       Getting target version for linear
#ioctl/libdm-iface.c:1673         dm versions   OF   [16384]
#activate/activate.c:363       Getting target version for striped
#ioctl/libdm-iface.c:1673         dm versions   OF   [16384]
#activate/dev_manager.c:907         Checking kernel supports striped segment type for lv2-real
#ioctl/libdm-iface.c:1673         dm deps   (254:0) OF   [16384]
#activate/dev_manager.c:907         Checking kernel supports striped segment type for lv2-real
#ioctl/libdm-iface.c:1673         dm deps   (254:1) OF   [16384]
#metadata/metadata.c:1564         Calculated readahead of LV lv2 is 256
#activate/dev_manager.c:907         Checking kernel supports snapshot segment type for lvol0
#activate/activate.c:363       Getting target version for snapshot
#ioctl/libdm-iface.c:1673         dm versions   OF   [16384]
#activate/activate.c:363       Getting target version for snapshot-origin
#ioctl/libdm-iface.c:1673         dm versions   OF   [16384]
#activate/dev_manager.c:907         Checking kernel supports snapshot segment type for lvol0-cow
#device/dev-io.c:396   WARNING: dev_open(/dev/mapper/loop2) called while suspended
#device/dev-io.c:486         Opened /dev/mapper/loop2 RW O_DIRECT
#device/dev-io.c:291       /dev/mapper/loop2: read_ahead is 256 sectors
#metadata/metadata.c:1564         Calculated readahead of LV lvol0 is 256
#metadata/metadata.c:1564         Calculated readahead of LV lvol0 is 256
#metadata/metadata.c:1564         Calculated readahead of LV lv2 is 256
#libdm-deptree.c:1184     Creating vg1-lv2-real
#ioctl/libdm-iface.c:1673         dm create vg1-lv2-real LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real NF   [16384]
#libdm-common.c:656         vg1-lv2-real: Stacking NODE_ADD (254,8) 0:0 0600
#libdm-deptree.c:1428     Loading vg1-lv2-real table (254:8)
#libdm-deptree.c:1374         Adding target to (254:8): 0 122880 linear 254:0 128
#libdm-deptree.c:1374         Adding target to (254:8): 122880 8192 linear 254:1 128
#ioctl/libdm-iface.c:1673         dm table   (254:8) OF   [16384]
#ioctl/libdm-iface.c:1673         dm reload   (254:8) NF   [16384]
#libdm-deptree.c:1468         Table size changed from 0 to 131072 for vg1-lv2-real
#libdm-deptree.c:894     Resuming vg1-lv2-real (254:8)
#ioctl/libdm-iface.c:1673         dm resume   (254:8) NF   [16384]
#libdm-common.c:684         vg1-lv2-real: Stacking NODE_READ_AHEAD 256 (flags=1)
#libdm-deptree.c:1184     Creating vg1-lv2
#ioctl/libdm-iface.c:1673         dm create vg1-lv2 LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO NF   [16384]
#libdm-common.c:656         vg1-lv2: Stacking NODE_ADD (254,9) 0:0 0600
#libdm-deptree.c:1428     Loading vg1-lv2 table (254:9)
#libdm-deptree.c:1374         Adding target to (254:9): 0 131072 snapshot-origin 254:8
#ioctl/libdm-iface.c:1673         dm table   (254:9) OF   [16384]
#ioctl/libdm-iface.c:1673         dm reload   (254:9) NF   [16384]
#libdm-deptree.c:1468         Table size changed from 0 to 131072 for vg1-lv2
#libdm-deptree.c:1184     Creating vg1-lvol0-cow
#ioctl/libdm-iface.c:1673         dm create vg1-lvol0-cow LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow NF   [16384]
#libdm-common.c:656         vg1-lvol0-cow: Stacking NODE_ADD (254,10) 0:0 0600
#libdm-deptree.c:1428     Loading vg1-lvol0-cow table (254:10)
#libdm-deptree.c:1374         Adding target to (254:10): 0 32768 linear 254:1 16512
#ioctl/libdm-iface.c:1673         dm table   (254:10) OF   [16384]
#ioctl/libdm-iface.c:1673         dm reload   (254:10) NF   [16384]
#libdm-deptree.c:1468         Table size changed from 0 to 32768 for vg1-lvol0-cow
#libdm-deptree.c:894     Resuming vg1-lvol0-cow (254:10)
#ioctl/libdm-iface.c:1673         dm resume   (254:10) NF   [16384]
#libdm-common.c:684         vg1-lvol0-cow: Stacking NODE_READ_AHEAD 256 (flags=1)
#libdm-deptree.c:1184     Creating vg1-lvol0
#ioctl/libdm-iface.c:1673         dm create vg1-lvol0 LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4 NF   [16384]
#libdm-common.c:656         vg1-lvol0: Stacking NODE_ADD (254,11) 0:0 0600
#libdm-deptree.c:1428     Loading vg1-lvol0 table (254:11)
#libdm-deptree.c:1374         Adding target to (254:11): 0 131072 snapshot 254:8 254:10 P 8
#ioctl/libdm-iface.c:1673         dm table   (254:11) OF   [16384]
#ioctl/libdm-iface.c:1673         dm reload   (254:11) NF   [16384]
#libdm-deptree.c:1468         Table size changed from 0 to 131072 for vg1-lvol0
#libdm-deptree.c:894     Resuming vg1-lvol0 (254:11)
#ioctl/libdm-iface.c:1673         dm resume   (254:11) NF   [16384]
#libdm-common.c:684         vg1-lvol0: Stacking NODE_READ_AHEAD 256 (flags=1)
#libdm-deptree.c:894     Resuming vg1-lv2 (254:9)
#ioctl/libdm-iface.c:1673         dm resume   (254:9) NF   [16384]
#libdm-common.c:684         vg1-lv2: Stacking NODE_READ_AHEAD 256 (flags=1)
#activate/dev_manager.c:631         Getting device info for vg1-lv2 [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:9) OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:8) OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:1) OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:0) OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2-real [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-real OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2-cow [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-cow OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2-cow  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lv2_mlog [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRTCEY6bqc2Md53jHZnoOTeyeMdMwH86ZO-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lv2_mlog  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0 [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4 OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:11) OF   [16384]
#ioctl/libdm-iface.c:1673         dm deps   (254:10) OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0-real [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-real OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0-real  OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0-cow [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-cow OF   [16384]
#activate/dev_manager.c:631         Getting device info for vg1-lvol0_mlog [LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog]
#ioctl/libdm-iface.c:1673         dm info  LVM-VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info  VOPJIMgCzp0x7r0a2Yi8O2xLd8mteXYRuPD584ugRJ4Xhx2fQC42wcGSn5aVArr4-_mlog OF   [16384]
#ioctl/libdm-iface.c:1673         dm info vg1-lvol0_mlog  OF   [16384]
#mm/memlock.c:118       Unlocking memory
#mm/memlock.c:137         memlock_count dec to 0
#libdm-common.c:360         Created /dev/mapper/vg1-lv2-real
#libdm-common.c:462         vg1-lv2-real: read ahead is 256
#libdm-common.c:485         vg1-lv2-real: Setting read ahead to 256
#libdm-common.c:360         Created /dev/mapper/vg1-lv2
#libdm-common.c:360         Created /dev/mapper/vg1-lvol0-cow
#libdm-common.c:462         vg1-lvol0-cow: read ahead is 256
#libdm-common.c:485         vg1-lvol0-cow: Setting read ahead to 256
#libdm-common.c:360         Created /dev/mapper/vg1-lvol0
#libdm-common.c:462         vg1-lvol0: read ahead is 256
#libdm-common.c:485         vg1-lvol0: Setting read ahead to 256
#libdm-common.c:462         vg1-lv2: read ahead is 256
#libdm-common.c:485         vg1-lv2: Setting read ahead to 256
#activate/fs.c:171       Linking /dev/vg1/lv2 -> /dev/mapper/vg1-lv2
#activate/fs.c:171       Linking /dev/vg1/lvol0 -> /dev/mapper/vg1-lvol0
#cache/lvmcache.c:71         Metadata cache: VG vg1 wiped.
#locking/file_locking.c:59       Unlocking /var/lock/lvm/V_vg1
#device/dev-io.c:532         Closed /dev/mapper/loop4
#device/dev-io.c:532         Closed /dev/mapper/loop1
#device/dev-io.c:532         Closed /dev/mapper/loop2
