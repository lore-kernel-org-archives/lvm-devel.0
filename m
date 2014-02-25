From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 23:23:19 +0000 (UTC)
Subject: master - snapshot: zero cow header for read-only snapshot
Message-ID: <20140225232319.146AF61016@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2b044452e30accf9ee026fc62ccea219bb4c7be4
Commit:        2b044452e30accf9ee026fc62ccea219bb4c7be4
Parent:        3bb9eda97c6ef2fb6848322e36b2b44a688ed37c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 26 00:17:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 00:22:46 2014 +0100

snapshot: zero cow header for read-only snapshot

When read-only snapshot was created, tool was skipping header
initialization of cow device.  If it happened device has been
already containing header from some previous snapshot, it's
been 'reused' for a newly created snapshot instead of being cleared.
---
 WHATS_NEW                    |    1 +
 test/shell/snapshot-usage.sh |   11 +++++++++++
 tools/lvcreate.c             |    8 ++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dd0821e..05218ee 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Zero snapshot COW header when creating read-only snapshot.
   Comment out config lines in dumpconfig output without default values defined.
   Improve detection of clustered mirror support.
   Enhance raid code with feature flags, for now checks for raid10.
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index fb88ae1..62a70e0 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -131,4 +131,15 @@ vgremove -ff $vg1
 
 fi
 
+lvremove -f $vg
+
+# Check snapshot really deletes COW header for read-only snapshot
+aux lvmconf "allocation/wipe_signatures_when_zeroing_new_lvs = 1"
+lvcreate -L10 -n $lv1 $vg
+lvcreate -s -L10 -n snap $vg/$lv1
+# Populate snapshot with some filesystem signatures
+mkfs.ext4 "$DM_DEV_DIR/$vg/snap"
+lvremove -f $vg/snap
+lvcreate -s -pr -l12 -n snap $vg/$lv1
+
 vgremove -ff $vg
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index dc473f8..ad00327 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -769,8 +769,12 @@ static int _read_activation_params(struct lvcreate_params *lp,
 	lp->permission = arg_uint_value(cmd, permission_ARG,
 					LVM_READ | LVM_WRITE);
 
-	/* Must not zero/wipe read only volume */
-	if (!(lp->permission & LVM_WRITE)) {
+	if (lp->snapshot) {
+		/* Snapshot has to zero COW header */
+		lp->zero = 1;
+		lp->wipe_signatures = 0;
+	} else if (!(lp->permission & LVM_WRITE)) {
+		/* Must not zero/wipe read only volume */
 		lp->zero = 0;
 		lp->wipe_signatures = 0;
 	}


