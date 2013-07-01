From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:36 +0000 (UTC)
Subject: master - cleanup: swap initial assignment
Message-ID: <20130701211336.36E1E60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdf0594aa8064bc08623bc56f934aa0dd44d9220
Commit:        bdf0594aa8064bc08623bc56f934aa0dd44d9220
Parent:        47419d21acec64a4d23968f6991a1d976673859f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 21:40:56 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:12:36 2013 +0200

cleanup: swap initial assignment

Easier to read code.
---
 tools/lvcreate.c |   30 ++++++++++--------------------
 1 files changed, 10 insertions(+), 20 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 69f8de0..057ccd5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1045,7 +1045,7 @@ static int _validate_internal_thin_processing(const struct lvcreate_params *lp)
 
 int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	int r = ECMD_PROCESSED;
+	int r = ECMD_FAILED;
 	struct lvcreate_params lp;
 	struct lvcreate_cmdline_params lcp;
 	struct volume_group *vg;
@@ -1060,34 +1060,24 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
-	if (lp.snapshot && lp.origin && !_determine_snapshot_type(vg, &lp)) {
-		r = ECMD_FAILED;
+	if (lp.snapshot && lp.origin && !_determine_snapshot_type(vg, &lp))
 		goto_out;
-	}
 
-	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp)) {
-		r = ECMD_FAILED;
+	if (seg_is_thin(&lp) && !_check_thin_parameters(vg, &lp, &lcp))
 		goto_out;
-	}
 
 	/*
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
 	 */
-	if (!_read_activation_params(&lp, cmd, vg)) {
-		r = ECMD_FAILED;
+	if (!_read_activation_params(&lp, cmd, vg))
 		goto_out;
-	}
 
-	if (!_update_extents_params(vg, &lp, &lcp)) {
-		r = ECMD_FAILED;
+	if (!_update_extents_params(vg, &lp, &lcp))
 		goto_out;
-	}
 
-	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp)) {
-		r = ECMD_FAILED;
+	if (seg_is_thin(&lp) && !_validate_internal_thin_processing(&lp))
 		goto_out;
-	}
 
 	if (lp.create_thin_pool)
 		log_verbose("Making thin pool %s in VG %s using segtype %s",
@@ -1100,10 +1090,10 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 			    lp.snapshot ? " as snapshot of " : "",
 			    lp.snapshot ? lp.origin : "", lp.segtype->name);
 
-	if (!lv_create_single(vg, &lp)) {
-		stack;
-		r = ECMD_FAILED;
-	}
+	if (!lv_create_single(vg, &lp))
+		goto_out;
+
+	r = ECMD_PROCESSED;
 out:
 	unlock_and_release_vg(cmd, vg, lp.vg_name);
 	return r;


