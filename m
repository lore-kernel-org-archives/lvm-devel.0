From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:12 +0000 (UTC)
Subject: dev-mornfall-lvmcache - pvremove: Avoid using pv_read in favour of scanning.
Message-ID: <20130605120612.0AAD061057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e9bbccb33da4dd23b6707914188f7ae611ec698
Commit:        4e9bbccb33da4dd23b6707914188f7ae611ec698
Parent:        93108125acda7092b227d6c64ae94d082d35a36b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 02:14:51 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:37 2013 +0200

pvremove: Avoid using pv_read in favour of scanning.

---
 tools/pvremove.c |   69 +++++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index 823c069..d53a37a 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -24,59 +24,60 @@ const char _really_wipe[] =
  */
 static int pvremove_check(struct cmd_context *cmd, const char *name)
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
 		if (arg_count(cmd, force_ARG))
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
-	if (is_orphan(pv) && !dm_list_size(&pv->fid->metadata_areas_in_use) &&
-	    !dm_list_size(&pv->fid->metadata_areas_ignored)) {
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
+		log_error("Physical Volume %s not found through scanning.", name);
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
 	if (arg_count(cmd, force_ARG) < 2) {
 		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
 		log_error("(If you are certain you need pvremove, then confirm by using --force twice.)");
-		goto bad;
+		goto out;
 	}
 
 	/* prompt */
 	if (!arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt(_really_wipe, name, pv_vg_name(pv)) == 'n') {
 		log_error("%s: physical volume label not removed", name);
-		goto bad;
+		goto out;
 	}
 
 	if (arg_count(cmd, force_ARG)) {
@@ -87,12 +88,12 @@ static int pvremove_check(struct cmd_context *cmd, const char *name)
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
 
 static int pvremove_single(struct cmd_context *cmd, const char *pv_name,


