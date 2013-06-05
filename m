From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:07 +0000 (UTC)
Subject: dev-mornfall-lvmcache - pvresize: Do not use pv_read (get the PV from orphan VG).
Message-ID: <20130605120607.D7AAD61057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d17cbf112bc6ada99e9ef1320bbfcb7114c153db
Commit:        d17cbf112bc6ada99e9ef1320bbfcb7114c153db
Parent:        d838501c446bccd1fbe6b4f4ad9ee2c78b5f8668
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 01:54:34 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

pvresize: Do not use pv_read (get the PV from orphan VG).

---
 lib/metadata/pv_manip.c |    2 +-
 tools/pvresize.c        |   45 +++++++++++++++------------------------------
 2 files changed, 16 insertions(+), 31 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 4a65a3e..fc678f9 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -513,7 +513,7 @@ int pv_resize(struct physical_volume *pv,
 	/* pv->pe_count is 0 now! We need to recalculate! */
 
 	/* If there's a VG, calculate new PE count value. */
-	if (vg) {
+	if (vg && !is_orphan_vg(vg->name)) {
 		/* FIXME: Maybe PE calculation should go into pv->fmt->resize?
 		          (like it is for pv->fmt->setup) */
 		if (!(new_pe_count = pv_size(pv) / vg->extent_size)) {
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 2f0693a..0a3d55a 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -37,38 +37,25 @@ static int _pv_resize_single(struct cmd_context *cmd,
 	struct volume_group *old_vg = vg;
 	int vg_needs_pv_write = 0;
 
-	if (is_orphan_vg(vg_name)) {
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
-			return 0;
-		}
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
-		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
-			return 0;
-		}
-	} else {
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-
-		if (vg_read_error(vg)) {
-			release_vg(vg);
-			log_error("Unable to read volume group \"%s\".",
-				  vg_name);
-			return 0;
-		}
+	if (vg_read_error(vg)) {
+		release_vg(vg);
+		log_error("Unable to read volume group \"%s\".",
+			  vg_name);
+		return 0;
+	}
 
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			goto out;
-		}
+	if (!(pvl = find_pv_in_vg(vg, pv_name))) {
+		log_error("Unable to find \"%s\" in volume group \"%s\"",
+			  pv_name, vg->name);
+		goto out;
+	}
 
-		pv = pvl->pv;
+	pv = pvl->pv;
 
-		if (!archive(vg))
-			goto out;
-	}
+	if (!archive(vg))
+		goto out;
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
 		log_error("Physical volume %s format does not support resizing.",
@@ -126,8 +113,6 @@ out:
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
 	unlock_vg(cmd, vg_name);
-	if (is_orphan_vg(vg_name))
-		free_pv_fid(pv);
 	if (!old_vg)
 		release_vg(vg);
 	return r;


