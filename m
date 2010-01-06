From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jan 2010 13:26:22 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/mirr ...
Message-ID: <20100106132622.21577.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-06 13:26:22

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	tools          : lvconvert.c 

Log message:
	Remove empty "repaired" devices if empty in lvconvert.
	
	The logic was that lvconvert repair volumes, marking
	PV as MISSING and following vgreduce --removemissing
	removes these missing devices.
	
	Previously dmeventd mirror DSO removed all LV and PV
	from VG by simply relying on
	vgreduce --removemissing --force.
	
	Now, there are two subsequent calls:
	lvconvert --repair --use-policies
	vgreduce --removemissing
	
	So the VG is locked twice, opening space for all races
	between other running lvm processes. If the PV reappears
	with old metadata on it (so the winner performs autorepair,
	if locking VG for update) the situation is even worse.
	
	Patch simply adds removemissing PV functionality into
	lvconcert BUT ONLY if running with --repair and --use-policies
	and removing only these empty missing PVs which are
	involved in repair.
	(This combination is expected to run only from dmeventd.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1365&r2=1.1366
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2010/01/06 13:25:36	1.1365
+++ LVM2/WHATS_NEW	2010/01/06 13:26:21	1.1366
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Remove empty PV devices if lvconvert --repair is using defined policies.
   Use fixed buffer to prevent stack overflow in persistent filter dump.
   Use snapshot metadata usage to determine if a snapshot is empty.
   Insert missing stack macros to all activate_lv and deactivate_lv callers.
--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/11/25 15:59:08	1.28
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/06 13:26:21	1.29
@@ -193,11 +193,7 @@
 
 	r = lvm2_run(_lvm_handle, cmd_str);
 
-	if (r == ECMD_PROCESSED) {
-		snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg);
-		if (lvm2_run(_lvm_handle, cmd_str) != 1)
-			syslog(LOG_ERR, "Unable to remove failed PVs from VG %s", vg);
-	}
+	syslog(LOG_INFO, "Repair of mirrored LV %s/%s %s.", vg, lv, (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
 
 	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 	return (r == ECMD_PROCESSED) ? 0 : -1;
--- LVM2/tools/lvconvert.c	2010/01/05 21:07:31	1.99
+++ LVM2/tools/lvconvert.c	2010/01/06 13:26:21	1.100
@@ -428,6 +428,16 @@
 		if (!(pvl->pv->status & MISSING_PV))
 			continue;
 
+		/* 
+		 * Finally, --repair will remove empty PVs.
+		 * But we only want remove these which are output of repair,
+		 * Do not count these which are already empty here.
+		 * FIXME: code should traverse PV in LV not in whole VG.
+		 * FIXME: layer violation? should it depend on vgreduce --removemising?
+		 */
+		if (pvl->pv->pe_alloc_count == 0)
+			continue;
+
 		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
 			log_error("Allocation of failed_pvs list entry failed.");
 			return_NULL;
@@ -522,6 +532,44 @@
 	return 1;
 }
 
+/*
+ * Reomove missing and empty PVs from VG, if are also in provided list
+ */
+static void _remove_missing_empty_pv(struct volume_group *vg, struct dm_list *remove_pvs)
+{
+	struct pv_list *pvl, *pvl_vg, *pvlt;
+	int removed = 0;
+
+	if (!remove_pvs)
+		return;
+
+	dm_list_iterate_items(pvl, remove_pvs) {
+		dm_list_iterate_items_safe(pvl_vg, pvlt, &vg->pvs) {
+			if (!id_equal(&pvl->pv->id, &pvl_vg->pv->id) ||
+			    !(pvl_vg->pv->status & MISSING_PV) ||
+			    pvl_vg->pv->pe_alloc_count != 0)
+				continue;
+
+			/* FIXME: duplication of vgreduce code, move this to library */
+			vg->free_count -= pvl_vg->pv->pe_count;
+			vg->extent_count -= pvl_vg->pv->pe_count;
+			vg->pv_count--;
+			dm_list_del(&pvl_vg->list);
+
+			removed++;
+		}
+	}
+
+	if (removed) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			stack;
+			return;
+		}
+
+		log_warn("%d missing and now unallocated Physical Volumes removed from VG.", removed);
+	}
+}
+
 static int _lvconvert_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 			      struct lvconvert_params *lp)
 {
@@ -532,7 +580,7 @@
 	int r = 0;
 	struct logical_volume *log_lv, *layer_lv;
 	int failed_mirrors = 0, failed_log = 0;
-	struct dm_list *old_pvh = NULL, *remove_pvs = NULL;
+	struct dm_list *old_pvh = NULL, *remove_pvs = NULL, *failed_pvs = NULL;
 
 	int repair = arg_count(cmd, repair_ARG);
 	int replace_log = 1, replace_mirrors = 1;
@@ -593,6 +641,7 @@
 		old_pvh = lp->pvh;
 		if (!(lp->pvh = _failed_pv_list(lv->vg)))
 			return_0;
+		failed_pvs = lp->pvh;
 		log_lv=first_seg(lv)->log_lv;
 		if (!log_lv || log_lv->status & PARTIAL_LV)
 			failed_log = corelog = 1;
@@ -821,6 +870,10 @@
 			goto restart;
 	}
 
+	/* If repairing and using policies, remove missing PVs from VG */
+	if (repair && arg_count(cmd, use_policies_ARG))
+		_remove_missing_empty_pv(lv->vg, failed_pvs);
+
 	if (!lp->need_polling)
 		log_print("Logical volume %s converted.", lv->name);
 


