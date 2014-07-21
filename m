From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 21 Jul 2014 15:01:58 +0000 (UTC)
Subject: master - config: Adjust description of activation_mode.
Message-ID: <20140721150158.182A160D23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=513fd029a635470522e1c8a9cdddb70eec39474a
Commit:        513fd029a635470522e1c8a9cdddb70eec39474a
Parent:        8c231a5f4d8e3e309dd018c92644580d06b11dd1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 21 15:50:47 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 21 15:50:47 2014 +0100

config: Adjust description of activation_mode.

---
 WHATS_NEW               |    3 ++-
 conf/example.conf.in    |   32 +++++++++++++++-----------------
 lib/activate/activate.c |    1 +
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 956b07b..c800dd0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -10,7 +10,8 @@ Version 2.02.108 -
   Prompt for confirmation before change LV into a snapshot exception store.
   Return proper error codes for some failing lvconvert funtions.
   Add initial code to use cache tools (cache_check|dump|repair|restore).
-  Add "degraded" activation mode and make it the default.
+  Support lvdisplay --maps for raid.
+  Add --activationmode degraded to activate degraded raid volumes by default.
   Add separate lv_active_{locally,remotely,exclusively} LV reporting fields.
   Recognize "auto"/"unmanaged" values in selection for appropriate fields only.
   Add report/binary_values_as_numeric lvm.conf option for binary values as 0/1.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 2930054..21c553a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1042,26 +1042,24 @@ activation {
     # operation is complete.
     polling_interval = 15
 
-    # 'activation_mode' determines how logical volumes are activated if
-    # devices are missing.  Possible settings are:
-    #
-    #	"complete" -  Only allow activation of an LV if all of the PVs
-    #		      that it uses are available (i.e. the volume group
-    #		      is complete).  There may be a failed PV in the
-    #		      volume group; but if a particular LV is not on that
-    #		      PV, it is still allowed to activate in this mode.
-    #
-    #	"degraded" -  Like "complete", except that RAID logical volumes of
-    #		      segment type "raid{1,4,5,6,10}" are activated if
-    #		      they have sufficient redundancy to present the entire
-    #		      addressable range of the logical volume.
-    #
-    #	"partial"  -  Allow activation for any logical volume - even if
-    #		      a missing or failed PV would cause a portion of the
-    #		      logical volume to be inaccessible.  (E.g. a stripe
-    #		      volume that has lost one of its members would be
-    #		      unable to access a portion of the logical volume.)
-    #		      This setting is not recommended for normal use.
+    # 'activation_mode' determines how Logical Volumes are activated if
+    # any devices are missing.  Possible settings are:
+    #
+    #	"complete" -  Only allow activation of an LV if all of the Physical
+    #		      Volumes it uses are present.  Other PVs in the Volume
+    #		      Group may be missing.
+    #
+    #	"degraded" -  Like "complete", but additionally RAID Logical Volumes of
+    #		      segment type raid1, raid4, raid5, radid6 and raid10 will
+    #		      be activated if there is no data loss, i.e. they have
+    #		      sufficient redundancy to present the entire addressable
+    #		      range of the Logical Volume.
+    #
+    #	"partial"  -  Allows the activation of any Logical Volume even if
+    #		      a missing or failed PV could cause data loss with a
+    #		      portion of the Logical Volume inaccessible.
+    #		      This setting should not normally be used, but may
+    #		      sometimes assist with data recovery.
     #
     # This setting was introduced in LVM version 2.02.108.  It corresponds
     # with the '--activationmode' option for lvchange and vgchange.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 70777fd..deb09e2 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2203,6 +2203,7 @@ out:
 	return r;
 }
 
+/* FIXME Move this non-activation code elsewhere */
 static int _lv_raid_is_redundant(struct logical_volume *lv)
 {
 	struct lv_segment *raid_seg = first_seg(lv);


