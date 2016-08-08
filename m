From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  8 Aug 2016 13:40:36 +0000 (UTC)
Subject: master - lvconvert: Limit --corelog and --mirrorlog to mirrors.
Message-ID: <20160808134036.AC8D060FFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c55134aa48644143ba398fdae30f47cb73b72ef9
Commit:        c55134aa48644143ba398fdae30f47cb73b72ef9
Parent:        7d6cf12554b0b6cbbee9db2f4da9439d6492a2b3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 8 14:25:46 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 8 14:39:55 2016 +0100

lvconvert: Limit --corelog and --mirrorlog to mirrors.

It's an error to specify a log when the final result is not of type
mirror.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ba8a0c..f438fc8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.163 - 
 =================================
+  Limit use of --corelog and --mirrorlog to mirrors in lvconvert.
   Do not refresh whole cmd context if profile dropped after processing LVM cmd.
   Support straightforward lvconvert between striped and raid4 LVs.
   Support straightforward lvconvert between raid1 and mirror LVs.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5677e9c..e7c34f7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1700,6 +1700,11 @@ static int _lvconvert_mirrors(struct cmd_context *cmd,
 	uint32_t new_mimage_count;
 	uint32_t new_log_count;
 
+	if (*lp->type_str && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
+		log_error("--corelog and --mirrorlog is only compatible with --type mirror");
+		return 0;
+	}
+
 	if (lp->merge_mirror) {
 		log_error("Unable to merge mirror images"
 			  "of segment type 'mirror'.");
@@ -1888,6 +1893,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		}
 	}
 
+	if ((lp->corelog || lp->mirrorlog) && strcmp(lp->type_str, SEG_TYPE_NAME_MIRROR)) {
+		log_error("--corelog and --mirrorlog is only compatible with --type mirror");
+		return 0;
+	}
+
 	if (lp->merge_mirror)
 		return lv_raid_merge(lv);
 
@@ -1898,7 +1908,8 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split(lv, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied) {
-		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR)) {
+		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||
+		    (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED) && image_count == 1)) {
 			if (!lv_raid_change_image_count(lv, image_count, lp->pvh))
 				return_0;
 


