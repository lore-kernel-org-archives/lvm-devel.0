From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 27 Jul 2007 11:32:52 -0400
Subject: [LVM2 PATCH 1/2] lvrename: add mirrored LV support
Message-ID: <46AA1024.5010606@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Currently, renaming is not supported for mirrored LVs:
# lvrename testvg/l testvg/newlv
  Mirrored LV, "l" cannot be renamed: Function not implemented

This patch enables mirrored LV renaming.

Mirrored LV contains "sub LV"s.
e.g. "lv0" contains "lv0_mimage_0", .., "lv0_mimage_n" and "lv0_mlog".
"_mimage" and "_mlog" are reserved words, so normal LVs never has
these in their names.
To rename mirrored LV, we have to rename those sub LVs accordingly.

The patch is tested on CVS head (pre 2.02.28) for the following cases:
  - normal LVs (linear, striped, snapshot) for regression check
  - mirrored LVs (-m2, -m1, --corelog for both active and inactive)

Example:

[Before renaming]
# lvs -a -o name
  LV
  l
  [l_mimage_0]
  [l_mimage_1]
  [l_mlog]
# dmsetup ls
testvg-l_mlog   (253, 9)
testvg-l_mimage_0       (253, 10)
testvg-l_mimage_1       (253, 11)
testvg-l        (253, 12)

# lvrename testvg/l testvg/newlv
  Renamed "l" to "newlv" in volume group "testvg"

[After renaming]
# lvs -a -o name
  LV
  newlv
  [newlv_mimage_0]
  [newlv_mimage_1]
  [newlv_mlog]
# dmsetup ls
testvg-newlv_mlog       (253, 9)
testvg-newlv_mimage_0   (253, 10)
testvg-newlv_mimage_1   (253, 11)
testvg-newlv    (253, 12)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvrename-support-mirror.patch
Type: text/x-patch
Size: 4504 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070727/8b1d2243/attachment.bin>
