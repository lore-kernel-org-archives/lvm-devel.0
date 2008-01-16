From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 18:15:27 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20080116181527.17394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 18:15:26

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : lvmcmdline.c pvcreate.c pvdisplay.c toollib.c 

Log message:
	use scan_vgs_for_pvs to detect non-orphans without MDAs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.762&r2=1.763
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/WHATS_NEW	2008/01/16 15:25:10	1.762
+++ LVM2/WHATS_NEW	2008/01/16 18:15:26	1.763
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Fix process_all_pvs to detect non-orphans with no MDAs correctly.
   Don't use block_on_error with mirror targets version 1.12 and above.
   Update vgsplit to include vgcreate-style options when new VG is destination.
   Update vgsplit to accept existing VG as destination.
--- LVM2/lib/metadata/metadata-exported.h	2008/01/15 22:56:30	1.33
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/16 18:15:26	1.34
@@ -310,6 +310,7 @@
 /* Set full_scan to 1 to re-read every (filtered) device label */
 struct list *get_vgs(struct cmd_context *cmd, int full_scan);
 struct list *get_vgids(struct cmd_context *cmd, int full_scan);
+int scan_vgs_for_pvs(struct cmd_context *cmd);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
--- LVM2/lib/metadata/metadata.c	2008/01/15 22:56:30	1.148
+++ LVM2/lib/metadata/metadata.c	2008/01/16 18:15:26	1.149
@@ -1015,7 +1015,16 @@
 		return NULL;
 	}
 
-	/* FIXME Can fail when no PV mda */
+	if (is_orphan_vg(pv->vg_name)) {
+		/* If a PV has no MDAs - need to search all VGs for it */
+		if (!scan_vgs_for_pvs(cmd))
+			return_NULL;
+		if (!(pv = _pv_read(cmd, pv_name, NULL, NULL, 1))) {
+			log_error("Physical volume %s not found", pv_name);
+			return NULL;
+		}
+	}
+
 	if (is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		return NULL;
@@ -1788,7 +1797,7 @@
 	return lvmcache_get_vgids(cmd, full_scan);
 }
 
-struct list *get_pvs(struct cmd_context *cmd)
+static int _get_pvs(struct cmd_context *cmd, struct list **pvslist)
 {
 	struct str_list *strl;
 	struct list *results;
@@ -1802,17 +1811,19 @@
 
 	lvmcache_label_scan(cmd, 0);
 
-	if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
-		log_error("PV list allocation failed");
-		return NULL;
-	}
+	if (pvslist) {
+		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
+			log_error("PV list allocation failed");
+			return NULL;
+		}
 
-	list_init(results);
+		list_init(results);
+	}
 
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 0))) {
 		log_error("get_pvs: get_vgs failed");
-		return NULL;
+		return 0;
 	}
 
 	/* Read every VG to ensure cache consistency */
@@ -1839,16 +1850,36 @@
 				 vgname);
 
 		/* Move PVs onto results list */
-		list_iterate_safe(pvh, tmp, &vg->pvs) {
-			list_add(results, pvh);
-		}
+		if (pvslist)
+			list_iterate_safe(pvh, tmp, &vg->pvs)
+				list_add(results, pvh);
 	}
 	init_pvmove(old_pvmove);
 	init_partial(old_partial);
 
+	if (pvslist)
+		*pvslist = results;
+	else
+		dm_pool_free(cmd->mem, vgids);
+
+	return 1;
+}
+
+struct list *get_pvs(struct cmd_context *cmd)
+{
+	struct list *results;
+
+	if (!_get_pvs(cmd, &results))
+		return NULL;
+
 	return results;
 }
 
+int scan_vgs_for_pvs(struct cmd_context *cmd)
+{
+	return _get_pvs(cmd, NULL);
+}
+
 /* FIXME: liblvm todo - make into function that takes handle */
 int pv_write(struct cmd_context *cmd __attribute((unused)),
 	     struct physical_volume *pv,
--- LVM2/tools/lvmcmdline.c	2008/01/16 17:14:56	1.58
+++ LVM2/tools/lvmcmdline.c	2008/01/16 18:15:26	1.59
@@ -584,7 +584,6 @@
 		a->ui64_value = 0;
 	}
 
-	memset(str, 0, sizeof(str));
 	/* fill in the short and long opts */
 	for (i = 0; i < cmd->command->num_args; i++)
 		_add_getopt_arg(cmd->command->valid_args[i], &ptr, &o);
--- LVM2/tools/pvcreate.c	2008/01/09 00:18:36	1.59
+++ LVM2/tools/pvcreate.c	2008/01/16 18:15:26	1.60
@@ -51,7 +51,8 @@
          * system.
 	 */
 	if (pv && is_orphan(pv)) {
-		(void) get_vgs(cmd, 1);
+		if (!scan_vgs_for_pvs(cmd))
+			return_0;
 		pv = pv_read(cmd, name, NULL, NULL, 0);
 	}
 
--- LVM2/tools/pvdisplay.c	2007/11/15 21:30:52	1.44
+++ LVM2/tools/pvdisplay.c	2008/01/16 18:15:26	1.45
@@ -26,7 +26,7 @@
 	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name = NULL;
 
-	 if (!is_orphan(pv) && !vg) {
+	if (!is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,
 					    LCK_VG_READ, CLUSTERED, 0))) {
--- LVM2/tools/toollib.c	2008/01/15 22:56:30	1.125
+++ LVM2/tools/toollib.c	2008/01/16 18:15:26	1.126
@@ -696,6 +696,7 @@
 	struct str_list *sll;
 	char *tagname;
 	int consistent = 1;
+	int scanned = 0;
 
 	list_init(&tags);
 
@@ -738,6 +739,30 @@
 					ret_max = ECMD_FAILED;
 					continue;
 				}
+
+        			/*
+			         * If a PV has no MDAs it may appear to be an
+				 * orphan until the metadata is read off
+				 * another PV in the same VG.  Detecting this
+				 * means checking every VG by scanning every
+				 * PV on the system.
+			         */
+				if (!scanned && is_orphan(pv)) {
+					if (!scan_vgs_for_pvs(cmd)) {
+						stack;
+						ret_max = ECMD_FAILED;
+						continue;
+					}
+					scanned = 1;
+					if (!(pv = pv_read(cmd, argv[opt],
+							   NULL, NULL, 1))) {
+						log_error("Failed to read "
+							  "physical volume "
+							  "\"%s\"", argv[opt]);
+						ret_max = ECMD_FAILED;
+						continue;
+					}
+				}
 			}
 
 			ret = process_single(cmd, vg, pv, handle);


