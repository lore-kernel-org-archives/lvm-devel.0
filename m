From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Nov 2015 13:41:46 +0000 (UTC)
Subject: master - cache: lvconvert repairs only thin pools
Message-ID: <20151119134146.99DBF610B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=795616a87bbb5fd2a3925e1445bb1a94ce718d55
Commit:        795616a87bbb5fd2a3925e1445bb1a94ce718d55
Parent:        d1608345dffd912dd591d71a147c5acf587cf7fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 19 13:32:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 19 14:40:24 2015 +0100

cache: lvconvert repairs only thin pools

Avoid internal error message where thin pool repair code tries to
fix cache pool - was catched later in code stack, so rather
catch this early and make the repair function exlusive
to thin pools.

So far we have no code for repairing cache pools
(other then the automatic during activation/deactivation).
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0519527..b0e79c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Show correct error message for unsupported yet cache pool repair.
   Allow lvconvert cache pools' data and metadata LV to raid.
   Fix reading of old metadata with missing cache policy or mode settings.
   Issue error if external_device_info_source=udev and udev db record incomplete.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 19ee607..72be45b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2320,9 +2320,9 @@ out:
 	return r;
 }
 
-static int _lvconvert_pool_repair(struct cmd_context *cmd,
-				  struct logical_volume *pool_lv,
-				  struct lvconvert_params *lp)
+static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
+				       struct logical_volume *pool_lv,
+				       struct lvconvert_params *lp)
 {
 	const char *dmdir = dm_dir();
 	const char *thin_dump =
@@ -3270,7 +3270,12 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (arg_count(cmd, repair_ARG)) {
 		if (lv_is_pool(lv)) {
-			if (!_lvconvert_pool_repair(cmd, lv, lp))
+			if (lv_is_cache_pool(lv)) {
+				log_error("Repair for cache pool %s not yet implemented.",
+					  display_lvname(lv));
+				return ECMD_FAILED;
+			}
+			if (!_lvconvert_thin_pool_repair(cmd, lv, lp))
 				return_ECMD_FAILED;
 			return ECMD_PROCESSED;
 		}


