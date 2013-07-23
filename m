From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jul 2013 23:16:08 +0000 (UTC)
Subject: master - thin: not zeroing for non-zeroed thin pool snaps
Message-ID: <20130723231608.7BC2E60E98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5597dc3652babd9a27064e001d654d5df7297ca7
Commit:        5597dc3652babd9a27064e001d654d5df7297ca7
Parent:        d00d45a8b609d50302c94a0fff20849f0cc13a48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 24 01:11:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 24 01:15:31 2013 +0200

thin: not zeroing for non-zeroed thin pool snaps

Do not zero initial 4KB of thin snapshot volume for thin pool with
disabled zeroing.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    2 +-
 test/shell/lvcreate-thin-snap.sh |    7 +++++++
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 36d9f93..fd44fb1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Do not zero init 4KB of thin snapshot for non-zeroing thin pool (2.02.94).
   Issue an error msg if lvconvert --type used incorrectly with other options.
   Use LOG_DEBUG/ERR msg severity instead default for lvm2-activation-generator.
   Support ARG_GROUPABLE with merge_synonym (for --raidwritemostly).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8fea33d..088c05d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5829,7 +5829,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	if (!seg_is_thin(lp) && !lp->zero && !lp->snapshot)
 		log_warn("WARNING: \"%s\" not zeroed", lv->name);
 	else if ((!seg_is_thin(lp) ||
-		  (lv_is_thin_volume(lv) &&
+		  (lv_is_thin_volume(lv) && !lp->snapshot &&
 		   !first_seg(first_seg(lv)->pool_lv)->zero_new_blocks)) &&
 		 !set_lv(cmd, lv, UINT64_C(0), 0)) {
 		log_error("Aborting. Failed to wipe %s.",
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 701bb08..a223469 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -54,4 +54,11 @@ lvcreate -K -s --name sn2 $vg/sn1
 lvcreate -K -s --name sn3 $vg/sn2
 lvcreate -K -s --name sn4 $vg/sn3
 
+lvremove -ff $vg
+
+lvcreate -L10M --zero n -T $vg/pool -V10M --name $lv1
+mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
+lvcreate -K -s $vg/$lv1 --name snap
+fsck -p $DM_DEV_DIR/$vg/snap
+
 vgremove -ff $vg


