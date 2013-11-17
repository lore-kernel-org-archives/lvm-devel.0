From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 17 Nov 2013 22:26:37 +0000 (UTC)
Subject: master - pvremove: Avoid using pv_read in favour of scanning.
Message-ID: <20131117222637.C485E60DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f5c12e3a88f6bc028e8355c58b6b2c89da301e7
Commit:        2f5c12e3a88f6bc028e8355c58b6b2c89da301e7
Parent:        fc02f241789824877d604ca40a56ab6487d7212a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 02:14:51 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Nov 17 21:41:27 2013 +0100

pvremove: Avoid using pv_read in favour of scanning.

---
 lib/metadata/pv_manip.c |   76 ++++++++++++++++++++++++----------------------
 1 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index b7a4b43..bee7972 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -652,59 +652,63 @@ const char _really_wipe[] =
 static int pvremove_check(struct cmd_context *cmd, const char *name,
 		unsigned force_count, unsigned prompt)
 {
-	struct physical_volume *pv;
+	struct device *dev;
+	struct label *label;
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
+
+	struct physical_volume *pv = NULL;
+	int r = 0;
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
+	if (!(dev = dev_cache_get(name, cmd->filter))) {
+		log_error("Device %s not found", name);
+		return 0;
+	}
+
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, 1, 0))) {
+	if (!label_read(dev, &label, 0)) {
 		if (force_count)
 			return 1;
-		log_error("Physical Volume %s not found", name);
+		log_error("No PV label found on %s.", name);
 		return 0;
 	}
 
-	/*
-	 * If a PV has no MDAs it may appear to be an
-	 * orphan until the metadata is read off
-	 * another PV in the same VG.  Detecting this
-	 * means checking every VG by scanning every
-	 * PV on the system.
-	 */
-	if (is_orphan(pv) && dm_list_empty(&pv->fid->metadata_areas_in_use) &&
-	    dm_list_empty(&pv->fid->metadata_areas_ignored)) {
-		if (!scan_vgs_for_pvs(cmd, 0)) {
-			log_error("Rescan for PVs without metadata areas "
-				  "failed.");
-			goto bad;
-		}
-		free_pv_fid(pv);
-		if (!(pv = pv_read(cmd, name, 1, 0))) {
-			log_error("Failed to read physical volume %s", name);
-			goto bad;
-		}
+	lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!(pvslist = get_pvs(cmd)))
+		return_0;
+
+	dm_list_iterate_items(pvl, pvslist)
+		if (pvl->pv->dev == dev)
+			pv = pvl->pv;
+
+	if (!pv) {
+		log_error(INTERNAL_ERROR "Physical Volume %s has a label,"
+			  " but is neither in a VG nor orphan.", name);
+		goto out; /* better safe than sorry */
 	}
 
-	/* orphan ? */
 	if (is_orphan(pv)) {
-		free_pv_fid(pv);
-		return 1;
+		r = 1;
+		goto out;
 	}
 
-	/* Allow partial & exported VGs to be destroyed. */
 	/* we must have -ff to overwrite a non orphan */
 	if (force_count < 2) {
 		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
 		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
-		goto bad;
+		goto out;
 	}
 
 	/* prompt */
 	if (!prompt &&
-	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
+	    yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" "
+			  "of volume group \"%s\" [y/n]? ",
+			  name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume label not removed", name);
-		goto bad;
+		goto out;
 	}
 
 	if (force_count) {
@@ -715,17 +719,17 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 			  !is_orphan(pv) ? "\"" : "");
 	}
 
-	free_pv_fid(pv);
-	return 1;
-
-bad:
-	free_pv_fid(pv);
-	return 0;
+	r = 1;
+out:
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+	return r;
 }
 
 int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		    void *handle __attribute__((unused)), unsigned force_count,
-		    unsigned prompt)
+	            unsigned prompt)
 {
 	struct device *dev;
 	int r = 0;


