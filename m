From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:38 +0000 (UTC)
Subject: master - lvchange: use better arg functions
Message-ID: <20160426213138.872F460663@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e77b6968b6b420a4d0d9f14af1386f28761f055b
Commit:        e77b6968b6b420a4d0d9f14af1386f28761f055b
Parent:        c215e1be5ce35177a0491c0d6495865efbe34b51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 26 22:04:19 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:29:58 2016 +0200

lvchange: use better arg functions

---
 tools/lvchange.c |   77 ++++++++++++++++++++++++++++++++---------------------
 1 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6a6a619..83da6bc 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -911,21 +911,32 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return_ECMD_FAILED;
 
 	if (!(lv->vg->status & LVM_WRITE) &&
-	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
-	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, discards_ARG) || arg_count(cmd, zero_ARG) ||
-	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG) ||
-	     arg_count(cmd, metadataprofile_ARG))) {
+	    arg_from_list_is_set(cmd, NULL,
+				 alloc_ARG,
+				 contiguous_ARG,
+				 discards_ARG,
+				 metadataprofile_ARG,
+				 permission_ARG,
+				 persistent_ARG,
+				 profile_ARG,
+				 readahead_ARG,
+				 zero_ARG,
+				 -1)) {
 		log_error("Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
 		return ECMD_FAILED;
 	}
 
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
-	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
-	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG) ||
-	     arg_count(cmd, metadataprofile_ARG))) {
+	    arg_from_list_is_set(cmd, NULL,
+				 alloc_ARG,
+				 contiguous_ARG,
+				 metadataprofile_ARG,
+				 permission_ARG,
+				 persistent_ARG,
+				 profile_ARG,
+				 readahead_ARG,
+				 -1)) {
 		log_error("Can't change logical volume \"%s\" under snapshot",
 			  lv->name);
 		return ECMD_FAILED;
@@ -1173,29 +1184,33 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 * --monitor or --poll).
 	 */
 	int update_partial_safe = /* options safe to update if partial */
-		arg_count(cmd, contiguous_ARG) ||
-		arg_count(cmd, permission_ARG) ||
-		arg_count(cmd, readahead_ARG) ||
-		arg_count(cmd, persistent_ARG) ||
-		arg_count(cmd, addtag_ARG) ||
-		arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, metadataprofile_ARG) ||
-		arg_count(cmd, profile_ARG) ||
-		arg_count(cmd, detachprofile_ARG) ||
-		arg_count(cmd, setactivationskip_ARG);
+		arg_from_list_is_set(cmd, NULL,
+				     addtag_ARG,
+				     contiguous_ARG,
+				     deltag_ARG,
+				     detachprofile_ARG,
+				     metadataprofile_ARG,
+				     permission_ARG,
+				     persistent_ARG,
+				     profile_ARG,
+				     readahead_ARG,
+				     setactivationskip_ARG,
+				     -1);
 	int update_partial_unsafe =
-		arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, discards_ARG) ||
-		arg_count(cmd, errorwhenfull_ARG) ||
-		arg_count(cmd, minrecoveryrate_ARG) ||
-		arg_count(cmd, maxrecoveryrate_ARG) ||
-		arg_count(cmd, resync_ARG) ||
-		arg_count(cmd, syncaction_ARG) ||
-		arg_count(cmd, cachepolicy_ARG) ||
-		arg_count(cmd, cachesettings_ARG) ||
-		arg_count(cmd, writebehind_ARG) ||
-		arg_count(cmd, writemostly_ARG) ||
-		arg_count(cmd, zero_ARG);
+		arg_from_list_is_set(cmd, NULL,
+				     alloc_ARG,
+				     cachepolicy_ARG,
+				     cachesettings_ARG,
+				     discards_ARG,
+				     errorwhenfull_ARG,
+				     maxrecoveryrate_ARG,
+				     minrecoveryrate_ARG,
+				     resync_ARG,
+				     syncaction_ARG,
+				     writebehind_ARG,
+				     writemostly_ARG,
+				     zero_ARG,
+				     -1);
 	int update = update_partial_safe || update_partial_unsafe;
 
 	if (!update &&


