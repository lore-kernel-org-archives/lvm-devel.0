From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Dec 2016 13:42:15 +0000 (UTC)
Subject: master - lvconvert: fix shown lv name for snapshot split
Message-ID: <20161219134215.5D0B160F3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb3f83357afd2b7462f5be9f409424f588a138c8
Commit:        eb3f83357afd2b7462f5be9f409424f588a138c8
Parent:        c90e9392e47a04f0d89c8ab0e0dca7fe9de00143
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 19 14:06:55 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 19 14:41:16 2016 +0100

lvconvert: fix shown lv name for snapshot split

We can't keep 'display_lvname' for too long - it's using
ringbuffer and keeps limited number of names. So it's
safe only per few simple tests,  but can't be used anymore
after some function calls..
(Fixes 00e641ef37a977129acc503f3fa1b67f556ac5eb)
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fbaa369..ab113ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix displayed lv name when splitting snapshot (2.02.146).
   Warn about command not making metadata backup just once per command.
   Enable usage of cached volume as thin volume's external origin.
   Support cache volume activation with -real layer.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 393d286..4103995 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2167,7 +2167,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return_0;
 
 	if (lv_is_pvmove(cow) || lv_is_mirror_type(cow) || lv_is_raid_type(cow) || lv_is_thin_type(cow)) {
-		log_error("LV %s type is unsupported with --splitsnapshot.", cow_name);
+		log_error("LV %s type is unsupported with --splitsnapshot.", display_lvname(cow));
 		return 0;
 	}
 
@@ -2179,8 +2179,8 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		    lv_is_visible(cow) &&
 		    lv_is_active(cow)) {
 			if (yes_no_prompt("Do you really want to split off active "
-					  "logical volume %s? [y/n]: ", cow_name) == 'n') {
-				log_error("Logical volume %s not split.", cow_name);
+					  "logical volume %s? [y/n]: ", display_lvname(cow)) == 'n') {
+				log_error("Logical volume %s not split.", display_lvname(cow));
 				return 0;
 			}
 		}
@@ -2189,14 +2189,14 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	if (!archive(vg))
 		return_0;
 
-	log_verbose("Splitting snapshot %s from its origin.", cow_name);
+	log_verbose("Splitting snapshot %s from its origin.", display_lvname(cow));
 
 	if (!vg_remove_snapshot(cow))
 		return_0;
 
 	backup(vg);
 
-	log_print_unless_silent("Logical Volume %s split from its origin.", cow_name);
+	log_print_unless_silent("Logical Volume %s split from its origin.", display_lvname(cow));
 
 	return 1;
 }


