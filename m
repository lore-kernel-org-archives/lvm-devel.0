From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:31 +0000 (GMT)
Subject: main - man: update lvmthin
Message-ID: <20210201114731.8BF023836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b218a7cfe7179ced64047374af51a883c1611c4d
Commit:        b218a7cfe7179ced64047374af51a883c1611c4d
Parent:        a690d16d29ff7d5e0cc1adb1fed2621efd5fafa4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 23 00:40:52 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:06:13 2021 +0100

man: update lvmthin

Add few more notes about thin-pool repair.
Fix couple typos.
---
 man/lvmthin.7_main | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index ce2343183..e6f1d6342 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -394,7 +394,7 @@ the pmspare LV.
 \&
 
 If thin pool metadata is damaged, it may be repairable.
-Checking and repairing thin pool metadata is analagous to
+Checking and repairing thin pool metadata is analogous to
 running fsck/repair on a file system.
 
 When a thin pool LV is activated, lvm runs the thin_check command
@@ -437,14 +437,24 @@ copy to the VG's pmspare LV.
 If step 1 is successful, the thin pool metadata LV is replaced
 with the pmspare LV containing the corrected metadata.
 The previous thin pool metadata LV, containing the damaged metadata,
-becomes visible with the new name ThinPoolLV_tmetaN (where N is 0,1,...).
-
-If the repair works, the thin pool LV and its thin LVs can be activated,
-and the LV containing the damaged thin pool metadata can be removed.
-It may be useful to move the new metadata LV (previously pmspare) to a
-better PV.
-
-If the repair does not work, the thin pool LV and its thin LVs are lost.
+becomes visible with the new name ThinPoolLV_metaN (where N is 0,1,...).
+
+If the repair works, the thin pool LV and its thin LVs can be activated.
+User should manually check if repaired thin pool kernel metadata
+has all data for all lvm2 known LVs by individual activation of
+every thin LV. When all works, user should continue with fsck of
+all filesystems present these such volumes.
+Once the thin pool is considered fully functional user may remove ThinPoolLV_metaN
+(the LV containing the damaged thin pool metadata) for possible
+space reuse.
+For a better performance it may be useful to pvmove the new repaired metadata LV
+(written to previous pmspare volume) to a better PV (i.e. SSD)
+
+If the repair operation fails, the thin pool LV and its thin LVs
+are not accessible and it may be necessary to restore their content
+from a backup.  In such case the content of unmodified original damaged
+ThinPoolLV_metaN volume can be used by your support for more
+advanced recovery methods.
 
 If metadata is manually restored with thin_repair directly,
 the pool metadata LV can be manually swapped with another LV
@@ -452,6 +462,9 @@ containing new metadata:
 
 .B lvconvert --thinpool VG/ThinPoolLV --poolmetadata VG/NewThinMetaLV
 
+Note: Thin pool metadata is compact so even small corruptions
+in them may result in significant portions of mappings to be lost.
+It is recommended to use fast resilient storage for them.
 
 .SS Activation of thin snapshots
 
@@ -549,7 +562,7 @@ Command to extend thin pool data space:
 .fi
 
 Other methods of increasing free data space in a thin pool LV
-include removing a thin LV and its related snapsots, or running
+include removing a thin LV and its related snapshots, or running
 fstrim on the file system using a thin LV.
 
 
@@ -689,7 +702,7 @@ with two configuration settings:
 .B thin_pool_autoextend_threshold
 .br
 is a percentage full value that defines when the thin pool LV should be
-extended.  Setting this to 100 disables automatic extention.  The minimum
+extended.  Setting this to 100 disables automatic extension.  The minimum
 value is 50.
 
 .BR lvm.conf (5)
@@ -716,7 +729,7 @@ the --ignoremonitoring option can be used.  With this option, the command
 will not ask dmeventd to monitor the thin pool LV.
 
 .IP \[bu]
-Setting thin_pool_autoextend_threshould to 100 disables automatic
+Setting thin_pool_autoextend_threshold to 100 disables automatic
 extension of thin pool LVs, even if they are being monitored by dmeventd.
 
 .P


