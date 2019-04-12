From: Eric Ren <renzhengeek@gmail.com>
Date: Fri, 12 Apr 2019 16:58:18 +0800
Subject: lvcreate hangs forever and udev work timeout
Message-ID: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

As subject, it seems a interaction problem between lvm and systemd-udev:

```
#lvm version
  LVM version:     2.02.130(2)-RHEL7 (2015-10-14)
  Library version: 1.02.107-RHEL7 (2015-10-14)
  Driver version:  4.35.0
```

lvm call trace when hangs:
```

(gdb) bt
#0  0x00007f7030b876a7 in semop () from /lib64/libc.so.6
#1  0x00007f70312b708c in _udev_wait (cookie=223161260) at libdm-common.c:2522
#2  dm_udev_wait (cookie=223161260) at libdm-common.c:2540
#3  0x000055e23866a60d in fs_unlock () at activate/fs.c:491
#4  0x000055e238677855 in _file_lock_resource (cmd=<optimized out>,
resource=<optimized out>, flags=256, lv=<optimized out>) at
locking/file_locking.c:64
#5  0x000055e23860a6c8 in _lock_vol (cmd=cmd at entry=0x55e239595000,
resource=<optimized out>, resource at entry=0x7ffe634b06b0 "#sync_names",
flags=flags at entry=256, lv_op=lv_op at entry=LV_NOOP,
    lv=lv at entry=0x0) at locking/locking.c:275
#6  0x000055e23860b013 in lock_vol (cmd=cmd at entry=0x55e239595000,
vol=<optimized out>, vol at entry=0x55e2386aae91 "#sync_names",
flags=flags at entry=256, lv=lv at entry=0x0) at locking/locking.c:355
#7  0x000055e23860bcf0 in sync_dev_names
(cmd=cmd at entry=0x55e239595000) at locking/locking.c:536
#8  0x000055e2385b4c4b in lvcreate (cmd=0x55e239595000,
argc=<optimized out>, argv=<optimized out>) at lvcreate.c:1534
#9  0x000055e2385bd388 in lvm_run_command
(cmd=cmd at entry=0x55e239595000, argc=1, argc at entry=8,
argv=0x7ffe634b0df0, argv at entry=0x7ffe634b0db8) at lvmcmdline.c:1655
#10 0x000055e2385bddf0 in lvm2_main (argc=8, argv=0x7ffe634b0db8) at
lvmcmdline.c:2121
```

systemd udev logs:
```
Apr 12 10:54:41 localhost.localdomain systemd-udevd[1363]: worker
[128147] /devices/virtual/block/dm-4 timeout; kill it
Apr 12 10:54:41 localhost.localdomain systemd-udevd[1363]: seq 2342985
'/devices/virtual/block/dm-4' killed
```

Is this a known issue? Please ask if any information needed :-)

Regards,
Eric


