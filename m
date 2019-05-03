From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 May 2019 15:39:56 -0400
Subject: master - pvscan: don't record PV online after error reading metadata
Message-ID: <201905031939.x43Jdug0006018@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1e9e21a171db49b75e1c7276b05ef2959a340c4e
Commit:        1e9e21a171db49b75e1c7276b05ef2959a340c4e
Parent:        607858538132a33a27039e0ff4796b1a7d9f4f32
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 2 16:54:28 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 3 14:39:42 2019 -0500

pvscan: don't record PV online after error reading metadata

---
 tools/pvscan.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index d3b2b8e..e389106 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -511,6 +511,7 @@ struct _pvscan_baton {
 	struct cmd_context *cmd;
 	struct volume_group *vg;
 	struct format_instance *fid;
+	int mda_read_errors;
 };
 
 static int _online_pvscan_single(struct metadata_area *mda, void *baton)
@@ -518,9 +519,13 @@ static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 	struct _pvscan_baton *b = baton;
 	struct volume_group *vg;
 
-	if (mda_is_ignored(mda) ||
-	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL)))
+	if (mda_is_ignored(mda))
 		return 1;
+	vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL);
+	if (!vg) {
+		b->mda_read_errors++;
+		return 1;
+	}
 
 	/* FIXME Also ensure contents match etc. */
 	if (!b->vg || vg->seqno > b->vg->seqno)
@@ -586,6 +591,7 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 
 	fmt = lvmcache_fmt(info);
 
+	memset(&baton, 0, sizeof(baton));
 	baton.cmd = cmd;
 	baton.vg = NULL;
 	baton.fid = fmt->ops->create_instance(fmt, &fic);
@@ -597,6 +603,16 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 
 	lvmcache_foreach_mda(info, _online_pvscan_single, &baton);
 
+	if (baton.mda_read_errors) {
+		/* Don't record the PV as online if there are errors reading the vg. */
+		log_print("pvscan[%d] PV %s ignore for metadata processing error.", getpid(), dev_name(dev));
+		if (baton.vg)
+			release_vg(baton.vg);
+		else
+			fmt->ops->destroy_instance(baton.fid);
+		return 1;
+	}
+
 	if (!baton.vg) {
 		if (pvid_without_metadata)
 			*pvid_without_metadata = dm_pool_strdup(cmd->mem, dev->pvid);


