From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:39:59 +0000 (UTC)
Subject: master - raid: query lock holder
Message-ID: <20141024143959.5583160641@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c7aae40a1bb1351680ec8c7afa12c2bf8b784a0
Commit:        1c7aae40a1bb1351680ec8c7afa12c2bf8b784a0
Parent:        e901a87a69bf8573e441790ebca2ca9376aaf8a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 21 10:53:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

raid: query lock holder

Ask for lock the proper LV.
Use the top-most LV to query for locally exclusive lock.

The rest of operations are then using 'lv_info()'

TODO:
  Check all devices are reloaded from proper level.
  In general any query on lv_is_active is supposed to be running
  ona lv_lock_holder() volume.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    2 +-
 tools/lvconvert.c         |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8b9cf6f..3b52595 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Query lock holding LV when replacing and converting raid volumes.
   Add extra validate for locked lv within validate_lv_cache_create().
   Add internal lvseg_name() function.
   Skip trying to file lock virtual internal vg name.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8219984..5237dc9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1555,7 +1555,7 @@ int lv_raid_replace(struct logical_volume *lv,
 	if (lv->status & PARTIAL_LV)
 		lv->vg->cmd->partial_activation = 1;
 
-	if (!lv_is_active_exclusive_locally(lv)) {
+	if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
 		log_error("%s/%s must be active %sto perform this operation.",
 			  lv->vg->name, lv->name,
 			  vg_is_clustered(lv->vg) ? "exclusive locally " : "");
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e976880..fc28846 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1902,7 +1902,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
 	if (arg_count(cmd, repair_ARG)) {
-		if (!lv_is_active_exclusive_locally(lv)) {
+		if (!lv_is_active_exclusive_locally(lv_lock_holder(lv))) {
 			log_error("%s/%s must be active %sto perform this"
 				  " operation.", lv->vg->name, lv->name,
 				  vg_is_clustered(lv->vg) ?


