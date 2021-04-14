From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 14 Apr 2021 09:07:37 +0000 (GMT)
Subject: main - Revert "thinpool: support lvconvert without zeroing"
Message-ID: <20210414090737.8A9D43989C82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87a3ea7f8f5194f916304e924f755bef0f03803c
Commit:        87a3ea7f8f5194f916304e924f755bef0f03803c
Parent:        94c264b9754c92a6d48ca7911a9db246490e64b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 14 10:26:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 14 10:53:34 2021 +0200

Revert "thinpool: support lvconvert without zeroing"

This reverts commit 8e7690b7980ad3bc6e7c38d6e2028f885751c355.

Actully this was bad idea - to make it on pair.
-Zn for thin-pools is already used - so here user must have
create new pool and swap existing thin-pool metadata into.

So reverting this commit to avoid any possible regression.
---
 tools/lvconvert.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index e8a38f33c..b50074294 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3086,8 +3086,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	/* Allow to have only thinpool active and restore it's active state. */
 	activate_pool = to_thinpool && lv_is_active(lv);
 
-	/* Wipe metadata_lv by default, but allow skipping on user's request. */
-	zero_metadata = arg_int_value(cmd, zero_ARG, 1);
+	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
+	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
 
 	/* An existing LV needs to have its lock freed once it becomes a data LV. */
 	if (vg_is_shared(vg) && lv->lock_args) {
@@ -3250,8 +3250,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	if (zero_metadata)
 		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-	else
-		log_warn("WARNING: Using mismatched pool metadata MAY DESTROY YOUR DATA!");
+	else if (to_cachepool)
+		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
 
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",


