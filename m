From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:15 +0000 (UTC)
Subject: master - cleanup: add some missing stack backtraces
Message-ID: <20120823124315.0F03BA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b300a803c0878e6c9a42aeb5d2c53ac7f64afed
Commit:        7b300a803c0878e6c9a42aeb5d2c53ac7f64afed
Parent:        109b3bb49b31d5fa7f6d0dd23345d703ab866ad6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 13 21:36:02 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

cleanup: add some missing stack backtraces

---
 lib/metadata/metadata.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index fd13b0a..205f77e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -645,19 +645,19 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 {
 	struct physical_volume *pv;
 
-	pv = pv_by_path(vg->fid->fmt->cmd, pv_name);
+	if (!(pv = pv_by_path(vg->fid->fmt->cmd, pv_name)))
+		stack;
 	if (!pv && !pp) {
 		log_error("%s not identified as an existing "
 			  "physical volume", pv_name);
 		return 0;
 	} else if (!pv && pp) {
-		pv = pvcreate_single(vg->cmd, pv_name, pp, 0);
-		if (!pv)
-			return 0;
+		if (!(pv = pvcreate_single(vg->cmd, pv_name, pp, 0)))
+			return_0;
 	}
 	if (!add_pv_to_vg(vg, pv_name, pv, pp)) {
 		free_pv_fid(pv);
-		return 0;
+		return_0;
 	}
 	return 1;
 }
@@ -679,7 +679,7 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 	char *pv_name;
 
 	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
-		return 0;
+		return_0;
 
 	/* attach each pv */
 	for (i = 0; i < pv_count; i++) {
@@ -1327,7 +1327,8 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, 0, 0);
+	if (!(pv = pv_read(cmd, name, 0, 0)))
+		stack;
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -1339,7 +1340,8 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 		free_pv_fid(pv);
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
-		pv = pv_read(cmd, name, 0, 0);
+		if (!(pv = pv_read(cmd, name, 0, 0)))
+			stack;
 	}
 
 	/* Allow partial & exported VGs to be destroyed. */
@@ -1513,7 +1515,7 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 				goto_bad;
 			log_error("uuid %s already in use on \"%s\"", buffer,
 				  dev_name(dev));
-			goto bad;;
+			goto bad;
 		}
 	}
 
@@ -2766,6 +2768,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 
 	if (!(pv = _pv_read(b->vg->cmd, b->vg->vgmem, dev_name(lvmcache_device(info)),
 			    b->vg->fid, b->warnings, 0))) {
+		stack;
 		return 1;
 	}
 


