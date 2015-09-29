From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 29 Sep 2015 16:29:03 +0000 (UTC)
Subject: master - lockd: fix rescanning VG metadata
Message-ID: <20150929162903.A61A360F10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=634bf8c953caba4550463281fc0a90ee43c80c8d
Commit:        634bf8c953caba4550463281fc0a90ee43c80c8d
Parent:        be393f6722bd89f3fe98ab1be2f1dd41609a0172
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 29 11:07:59 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 29 11:28:48 2015 -0500

lockd: fix rescanning VG metadata

One host changes a VG, making the cached VG on another
host invalid.  The other host then rereads the VG from
disk to get the latest copy.  If the first host removed
a PV from the VG, the second host attempts to reread the
VG from old PV when rescanning.  Reading the VG from the
removed PV fails, causing vg_read to return "VG not found".
The fix is to simply not fail when a VG is not found while
rereading a PV and continue without it.

(This doesn't happen if the second host happens to first
run a command like 'vgs' that triggers a global revalidation
of metadata.)
---
 lib/cache/lvmetad.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0fff65a..721c4a2 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1122,6 +1122,8 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
  * due to something like an lvcreate from another host.
  * This is limited to changes that only affect the vg (not global state like
  * orphan PVs), so we only need to reread mdas on the vg's existing pvs.
+ * But, a previous PV in the VG may have been removed since we last read
+ * the VG, and that PV may have been reused for another VG.
  */
 
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
@@ -1160,9 +1162,25 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 
 		lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
+		/*
+		 * The PV may have been removed from the VG by another host
+		 * since we last read the VG.
+		 */
 		if (!baton.vg) {
+			log_debug_lvmetad("Did not find VG %s in scan of PV %s", vg->name, dev_name(pvl->pv->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
-			return NULL;
+			continue;
+		}
+
+		/*
+		 * The PV may have been removed from the VG and used for a
+		 * different VG since we last read the VG.
+		 */
+		if (strcmp(baton.vg->name, vg->name)) {
+			log_debug_lvmetad("Did not find VG %s in scan of PV %s which is now VG %s",
+					  vg->name, dev_name(pvl->pv->dev), baton.vg->name);
+			release_vg(baton.vg);
+			continue;
 		}
 
 		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {


