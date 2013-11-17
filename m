From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:33 +0000 (UTC)
Subject: master - pvresize: Do not use pv_read (get the PV from orphan VG).
Message-ID: <20131117222633.80A7B60DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=603b45e0ed1032875f587eda3391c47b6652303c
Commit:        603b45e0ed1032875f587eda3391c47b6652303c
Parent:        0a59305c44e992831d66da50f5058f154a795d3a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 01:54:34 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

pvresize: Do not use pv_read (get the PV from orphan VG).

---
 lib/metadata/pv_manip.c |   51 ++++++++++++++++------------------------------
 1 files changed, 18 insertions(+), 33 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index fb29ef4..b7a4b43 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -549,9 +549,9 @@ static int pv_resize(struct physical_volume *pv,
 }
 
 int pv_resize_single(struct cmd_context *cmd,
-			     struct volume_group *vg,
-			     struct physical_volume *pv,
-			     const uint64_t new_size)
+		     struct volume_group *vg,
+		     struct physical_volume *pv,
+		     const uint64_t new_size)
 {
 	struct pv_list *pvl;
 	uint64_t size = 0;
@@ -561,38 +561,25 @@ int pv_resize_single(struct cmd_context *cmd,
 	struct volume_group *old_vg = vg;
 	int vg_needs_pv_write = 0;
 
-	if (is_orphan_vg(vg_name)) {
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
-			log_error("Can't get lock for orphans");
-			return 0;
-		}
-
-		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
-			return 0;
-		}
-	} else {
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 
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
@@ -650,8 +637,6 @@ out:
 		log_error("Use pvcreate and vgcfgrestore "
 			  "to repair from archived metadata.");
 	unlock_vg(cmd, vg_name);
-	if (is_orphan_vg(vg_name))
-		free_pv_fid(pv);
 	if (!old_vg)
 		release_vg(vg);
 	return r;


