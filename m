From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 13:31:27 +0000 (UTC)
Subject: master - lv_remove_single: add silent arg
Message-ID: <20131204133127.2491460EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a6794a2ce74416c399f8cf28f2625de8ba9cd55
Commit:        5a6794a2ce74416c399f8cf28f2625de8ba9cd55
Parent:        84b3852ee5ed6d6a254ec4ffa9254db034c902bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 29 17:00:55 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 14:30:25 2013 +0100

lv_remove_single: add silent arg

Support silence for removal message.
---
 WHATS_NEW                        |    1 +
 lib/metadata/lv_manip.c          |    6 +++---
 lib/metadata/metadata-exported.h |    2 +-
 liblvm/lvm_lv.c                  |    2 +-
 tools/lvconvert.c                |    2 +-
 5 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa97962..c7c028a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Extend lv_remove_single() to not print info about removed LV.
   Replace open_count check with lv_check_not_in_use() for snapshot open test.
   Add error messages with LV names for failing lv refresh.
   Compile/link daemons with RELRO and PIE options to harden daemon security.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c67dd38..6846f4a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4482,7 +4482,7 @@ void lv_set_hidden(struct logical_volume *lv)
 }
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		     const force_t force)
+		     force_t force, int silent)
 {
 	struct volume_group *vg;
 	struct lvinfo info;
@@ -4639,7 +4639,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	backup(vg);
 
-	if (visible)
+	if (!silent && visible)
 		log_print_unless_silent("Logical volume \"%s\" successfully removed", lv->name);
 
 	return 1;
@@ -4764,7 +4764,7 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n'))
 		goto no_remove;
 
-	return lv_remove_single(cmd, lv, force);
+	return lv_remove_single(cmd, lv, force, 0);
 
 no_remove:
 	log_error("Logical volume \"%s\" not removed.", lv->name);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f205a14..0186c61 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -657,7 +657,7 @@ int lv_extend(struct logical_volume *lv,
 int lv_remove(struct logical_volume *lv);
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		     force_t force);
+		     force_t force, int silent);
 
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
 				force_t force, unsigned level);
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index f5c3ab9..b451c83 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -206,7 +206,7 @@ int lvm_vg_remove_lv(lv_t lv)
 		return -1;
 	if (!vg_check_write_mode(lv->vg))
 		return -1;
-	if (!lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT))
+	if (!lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT, 0))
 		return -1;
 	return 0;
 }
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ab1d5a3..a0fa679 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -683,7 +683,7 @@ static int _finish_lvconvert_merge(struct cmd_context *cmd,
 	}
 
 	log_print_unless_silent("Merge of snapshot into logical volume %s has finished.", lv->name);
-	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT)) {
+	if (!lv_remove_single(cmd, snap_seg->cow, DONT_PROMPT, 0)) {
 		log_error("Could not remove snapshot %s merged into %s.",
 			  snap_seg->cow->name, lv->name);
 		return 0;


