From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 May 2014 20:15:49 +0000 (UTC)
Subject: master - man: lvmthin cover snapshot merge and xfs
Message-ID: <20140514201549.B7BE36036A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42d7409da2761198781e067b81a4dca86ba27ee9
Commit:        42d7409da2761198781e067b81a4dca86ba27ee9
Parent:        044b7968005a23e52a78c26eb56a7f74a973312f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 14 14:05:21 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 14 15:15:35 2014 -0500

man: lvmthin cover snapshot merge and xfs

also fix a couple inconsistent example values.
---
 man/lvmthin.7.in |  115 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 112 insertions(+), 3 deletions(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index 5a4ee87..030745b 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -104,7 +104,7 @@ The primary method for using lvm thin provisioning:
    lvcreate -n ThinDataLV -L LargeSize VG
 
    Example
-   # lvcreate -n pool0 -L 100G vg
+   # lvcreate -n pool0 -L 10G vg
 
 2. create ThinMetaLV
 
@@ -251,6 +251,10 @@ Single step thin pool LV creation
 .br
 Single step thin pool LV and thin LV creation
 .br
+Merge thin snapshots
+.br
+XFS on snapshots
+.br
 
 \&
 
@@ -269,7 +273,7 @@ lvcreate -n ThinMetaLV -L SmallSize VG SmallPV
 lvconvert --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
 
 Example
-# lvcreate -n pool0 -L 100G vg /dev/sdA
+# lvcreate -n pool0 -L 10G vg /dev/sdA
 # lvcreate -n pool0meta -L 1G vg /dev/sdB
 # lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
 .fi
@@ -293,7 +297,7 @@ lvcreate --type raid1 -m 1 -n ThinDataLV -L LargeSize VG PVC PVD
 lvconvert --thinpool VG/ThinDataLV --poolmetadata VG/ThinMetaLV
 
 Example
-# lvcreate --type raid1 -m 1 -n pool0 -L 100G vg /dev/sdA /dev/sdB
+# lvcreate --type raid1 -m 1 -n pool0 -L 10G vg /dev/sdA /dev/sdB
 # lvcreate --type raid1 -m 1 -n pool0meta -L 1G vg /dev/sdC /dev/sdD
 # lvconvert --thinpool vg/pool0 --poolmetadata vg/pool0meta
 .fi
@@ -981,6 +985,111 @@ pool0           vg          twi-a-tz--   8.00m
 thin1           vg          Vwi-a-tz--   2.00g pool0
 .fi
 
+
+.SS Merge thin snapshots
+
+\&
+
+A thin snapshot can be merged into its origin thin LV using the lvconvert
+--merge command.  The result of a snapshot merge is that the origin thin
+LV takes the content of the snapshot LV, and the snapshot LV is removed.
+Any content that was unique to the origin thin LV is lost after the merge.
+
+Because a merge changes the content of an LV, it cannot be done while the
+LVs are open, e.g. mounted.  If a merge is initiated while the LVs are open,
+the effect of the merge is delayed until the origin thin LV is next
+activated.
+
+.nf
+lvconvert --merge VG/SnapLV
+
+Example
+# lvs vg
+LV      VG Attr       LSize   Pool  Origin
+pool0   vg twi-a-tz--  10.00g
+thin1   vg Vwi-a-tz-- 100.00g pool0
+thin1s1 vg Vwi-a-tz-k 100.00g pool0 thin1
+
+# lvconvert --merge vg/thin1s1
+
+# lvs vg
+LV      VG Attr       LSize   Pool  Origin
+pool0   vg twi-a-tz--  10.00g
+thin1   vg Vwi-a-tz-- 100.00g pool0
+.fi
+
+.nf
+Example
+
+Delayed merging of open LVs.
+
+# lvs vg
+LV      VG Attr       LSize   Pool  Origin
+pool0   vg twi-a-tz--  10.00g
+thin1   vg Vwi-aotz-- 100.00g pool0
+thin1s1 vg Vwi-aotz-k 100.00g pool0 thin1
+
+# df
+/dev/mapper/vg-thin1            100G   33M  100G   1% /mnt/X
+/dev/mapper/vg-thin1s1          100G   33M  100G   1% /mnt/Xs
+
+# ls /mnt/X
+file1 file2 file3
+# ls /mnt/Xs
+file3 file4 file5
+
+# lvconvert --merge vg/thin1s1
+Logical volume vg/thin1s1 contains a filesystem in use.
+Delaying merge since snapshot is open.
+Merging of thin snapshot thin1s1 will occur on next activation.
+
+# umount /mnt/X
+# umount /mnt/Xs
+
+# lvs -a vg
+LV              VG   Attr       LSize   Pool  Origin
+pool0           vg   twi-a-tz--  10.00g
+[pool0_tdata]   vg   Twi-ao----  10.00g
+[pool0_tmeta]   vg   ewi-ao----   1.00g
+thin1           vg   Owi-a-tz-- 100.00g pool0
+[thin1s1]       vg   Swi-a-tz-k 100.00g pool0 thin1
+
+# lvchange -an vg/thin1
+# lvchange -ay vg/thin1
+
+# mount /dev/vg/thin1 /mnt/X
+
+# ls /mnt/X
+file3 file4 file5 
+.fi
+
+
+.SS XFS on snapshots
+
+\&
+
+Mounting an XFS file system on a new snapshot LV requires attention to the
+file system's log state and uuid.  On the snapshot LV, the xfs log will
+contain a dummy transaction, and the xfs uuid will match the uuid from the
+file system on the origin LV.
+
+If the snapshot LV is writable, mounting will recover the log to clear the
+dummy transaction, but will require skipping the uuid check:
+
+mount /dev/VG/SnapLV /mnt -o nouuid
+
+Or, the uuid can be changed on disk before mounting:
+
+xfs_admin -U generate /dev/VG/SnapLV
+.br
+mount /dev/VG/SnapLV /mnt
+
+If the snapshot LV is readonly, the log recovery and uuid check need to be
+skipped while mounting readonly:
+
+mount /dev/VG/SnapLV /mnt -o ro,nouuid,norecovery
+
+
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),


