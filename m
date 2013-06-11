From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 17:50:16 +0000 (UTC)
Subject: master - lvresize: improve poolmetadatasize
Message-ID: <20130611175016.ED1A86125B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb70b38021992dd462a94d40527a315ce1e692fd
Commit:        bb70b38021992dd462a94d40527a315ce1e692fd
Parent:        6ff8b6d7548b218f678c45f768b8383038db1855
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 19:46:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 19:46:42 2013 +0200

lvresize: improve poolmetadatasize

Fix the usecase when only PV list is specified.
With --poolmetadatasize PV list is used for metadata extents.
Without --poolmetadatasize PV list is used for 100% extension of LV.
Handle the case, when nothing could be resized (i.e. in dmeventd)
---
 tools/lvresize.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 3e2c281..9139228 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -214,12 +214,15 @@ static int _lvresize_params(struct cmd_context *cmd, int argc, char **argv,
 		 * Allow omission of extents and size if the user has given us
 		 * one or more PVs.  Most likely, the intent was "resize this
 		 * LV the best you can with these PVs"
+		 * If only --poolmetadatasize is specified with list of PVs,
+		 * then metadata will be extended there.
 		 */
 		lp->sizeargs = arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG);
 		if ((lp->sizeargs == 0) && (argc >= 2)) {
 			lp->extents = 100;
 			lp->percent = PERCENT_PVS;
 			lp->sign = SIGN_PLUS;
+			lp->sizeargs = !lp->poolmetadatasize ? 1 : 0;
 		} else if ((lp->sizeargs != 1) &&
 			   ((lp->sizeargs == 2) ||
 			    !arg_count(cmd, poolmetadatasize_ARG))) {
@@ -429,8 +432,11 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		return 2;
 	}
 
+	if (!lp->sizeargs && !archive(vg))
+		return_0;
+
 	log_print_unless_silent("Extending logical volume %s to %s.",
-                                lv->name,
+				lv->name,
 				display_size(cmd, (uint64_t) extents * vg->extent_size));
 	mseg = last_seg(lv);
 	seg_mirrors = lv_mirror_count(lv);
@@ -575,7 +581,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return ECMD_FAILED;
 	}
 
-	if (lp->sizeargs || (pvh != &vg->pvs)) { /* TODO: reindent or move to function */
+	if (lp->sizeargs) { /* TODO: reindent or move to function */
 
 	switch(lp->percent) {
 		case PERCENT_VG:
@@ -954,6 +960,9 @@ metadata_resize:
 		lock_lv = lv;
 	}
 
+	if (!lock_lv)
+		return ECMD_PROCESSED; /* Nothing to do */
+
 	/* store vg on disk(s) */
 	if (!vg_write(vg)) {
 		stack;


