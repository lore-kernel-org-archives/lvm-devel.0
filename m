From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:07 +0000 (GMT)
Subject: main - thinpool: support lvconvert without zeroing
Message-ID: <20210318181507.34E8F3844031@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e7690b7980ad3bc6e7c38d6e2028f885751c355
Commit:        8e7690b7980ad3bc6e7c38d6e2028f885751c355
Parent:        1c3774c7a834bd0ad0dcf356f694e123d8955d9d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 17 19:09:58 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 18:57:45 2021 +0100

thinpool: support lvconvert without zeroing

Since lvm does support external users of thin-pool when thin devices
are managed outside it can be useful to support conversion to
thin pool from data and metadata LV without zeroing.
TransactionID will be 0 in lvm2 metadata.

  lvconvert -Zn --thinpool vg/data --poolmetadata vg/meta
---
 tools/lvconvert.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b50074294..e8a38f33c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3086,8 +3086,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	/* Allow to have only thinpool active and restore it's active state. */
 	activate_pool = to_thinpool && lv_is_active(lv);
 
-	/* Wipe metadata_lv by default, but allow skipping this for cache pools. */
-	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
+	/* Wipe metadata_lv by default, but allow skipping on user's request. */
+	zero_metadata = arg_int_value(cmd, zero_ARG, 1);
 
 	/* An existing LV needs to have its lock freed once it becomes a data LV. */
 	if (vg_is_shared(vg) && lv->lock_args) {
@@ -3250,8 +3250,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	if (zero_metadata)
 		log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
-	else if (to_cachepool)
-		log_warn("WARNING: Using mismatched cache pool metadata MAY DESTROY YOUR DATA!");
+	else
+		log_warn("WARNING: Using mismatched pool metadata MAY DESTROY YOUR DATA!");
 
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",


