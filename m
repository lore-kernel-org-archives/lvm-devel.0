From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 10 Feb 2009 22:26:58 -0500
Subject: lvm2: warning after mirrored LV is initialized as PV
Message-ID: <49924582.3040708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote (in dm-devel)
> Note that once you get #1 done you /should/ be able to get a mirrored  
> log by:
> prompt> lvcreate -m1 --mirrorlog core -l 1 -n mirrored_log vg
> prompt> lvcreate -m1 -L 5G -n mirror vg /dev/sdb /dev/sdc /dev/vg/ 
> mirrored_log

I'm now evaluating the layered LV approach, which was suggested by Jon,
with the latest LVM command (2.02.45), but some warning messages are
displayed after mirrored LV was initialized as PV.

# /sbin/dmsetup ls --tree
vg--mirror-mirror (253:6)
 ??vg--mirror-mirror_mimage_1 (253:5)
 ?  ?? (8:80)
 ??vg--mirror-mirror_mimage_0 (253:4)
 ?  ?? (8:64)
 ??vg--mirror-mirror_mlog (253:3)
    ??vg--log-mirror--log (253:2)
       ??vg--log-mirror--log_mimage_1 (253:1)
       ?  ?? (8:32)
       ??vg--log-mirror--log_mimage_0 (253:0)
          ?? (8:48)

# vgs
  Found duplicate PV DoSlX0JCU3qxxN4UVqgtqvzP1crZAwom: using \
  /dev/mapper/vg--log-mirror--log_mimage_1 not \
  /dev/mapper/vg--log-mirror--log_mimage_0
  Found duplicate PV DoSlX0JCU3qxxN4UVqgtqvzP1crZAwom: using \
  /dev/vg-log/mirror-log not /dev/mapper/vg--log-mirror--log_mimage_1
  VG        #PV #LV #SN Attr   VSize  VFree
  vg-log      2   1   0 wz--n- 31.99G 31.97G
  vg-mirror   3   1   0 wz--n- 32.00G 31.97G

This warning message is displayed during scan of PVs because the
following three logical volumes have the same UUID.

    /dev/vg-log/mirror-log
    /dev/mapper/vg--log-mirror--log_mimage_0
    /dev/mapper/vg--log-mirror--log_mimage_1

And this warning can be avoided by setting filter in config file, but
I hope that these warnings are not displayed without a config setting.

    filter = [ ..., "r|.*_mimage_.$|", ... ]

Do you think it is reasonable idea to skip device scan of LVs which have
a string, "_mimage_", in their name? I think that adding a static filter
for "_mimage_" in lvm commands is one of the solutions.

I appreciate your kind comments to fix this issue.

Thanks,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


