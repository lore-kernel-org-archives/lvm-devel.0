From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:08:58 +0000 (UTC)
Subject: master - snapshot: use lv_check_not_in_use
Message-ID: <20131122200858.CFE6E60EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a061a35c7523d0a1657a52fc179b520d6bcf4d2
Commit:        4a061a35c7523d0a1657a52fc179b520d6bcf4d2
Parent:        6d196410fc071cfe15638bbde0b3ac8bbbf4be53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 15:27:47 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:58:11 2013 +0100

snapshot: use lv_check_not_in_use

Instead of plain open_count check, try to use 'smarter'
lv_check_not_in_use() function.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   19 ++++++++-----------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 119463b..9b18ef0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Use lv_check_not_in_use() when testing device in use before merging.
   Move test for target present from init_snapshot_merge() to lvconvert.
   Check for failure of lvmcache_add_mda() when writing pv.
   Check for failure of dev_get_size() when reporting device size.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a7281b..a15bd75 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1906,17 +1906,14 @@ static int lvconvert_merge(struct cmd_context *cmd,
 	 * constructor and DM should prevent appropriate devices from
 	 * being open.
 	 */
-	if (lv_info(cmd, origin, 0, &info, 1, 0)) {
-		if (info.open_count) {
-			log_error("Can't merge over open origin volume");
-			merge_on_activate = 1;
-		}
-	}
-	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (info.open_count) {
-			log_print_unless_silent("Can't merge when snapshot is open");
-			merge_on_activate = 1;
-		}
+	if (lv_info(cmd, origin, 0, &info, 1, 0) &&
+	    !lv_check_not_in_use(cmd, origin, &info)) {
+		log_print_unless_silent("Can't merge over open origin volume.");
+		merge_on_activate = 1;
+	} else if (lv_info(cmd, lv, 0, &info, 1, 0) &&
+		   !lv_check_not_in_use(cmd, lv, &info)) {
+		log_print_unless_silent("Can't merge when snapshot is open.");
+		merge_on_activate = 1;
 	}
 
 	init_snapshot_merge(snap_seg, origin);


