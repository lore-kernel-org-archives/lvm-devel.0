From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 13:55:50 -0400
Subject: [LVM2 PATCH] Add lv_is_internal() to check internal LVs
Message-ID: <46BB5526.5030706@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Internal LVs ("snapshotX", mirror logs and mimages) should
not be directly manipulated from commands.

Currently, it's allowed in some places, though.
# lvs -a
  LV               VG     Attr   LSize Origin Snap%  Move Log        Copy% 
  lvol0            testvg -wi-a- 4.00M                                     
  lvol2            testvg mwi-a- 4.00M                    lvol2_mlog 100.00
  [lvol2_mimage_0] testvg iwi-ao 4.00M                                     
  [lvol2_mimage_1] testvg iwi-ao 4.00M                                     
  [lvol2_mlog]     testvg lwi-ao 4.00M          
# lvresize -l+1 testvg/lvol2_mimage_1
  Extending logical volume lvol2_mimage_1 to 8.00 MB
# lvconvert -s testvg/lvol2_mimage_1 testvg/lvol0
  Logical volume lvol0 converted to snapshot.
# lvrename testvg/snapshot0 testvg/s
  Renamed "snapshot0" to "s" in volume group "testvg"
# lvconvert -m1 testvg/s
  Logical volume s converted.

Until the stacking of LVs are properly supported,
it's safer to disable them.

Attached patch adds lv_is_internal() to check internal LVs.
lv_is_visible() returns true for "snapshotX" so it can't
directly usable for this purpose.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-lv_is_internal.patch
Type: text/x-patch
Size: 3164 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/eebfd8c3/attachment.bin>
