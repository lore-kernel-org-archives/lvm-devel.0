From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 12:38:31 -0000
Subject: LVM2 tools/pvremove.c ./WHATS_NEW
Message-ID: <20080731123831.14093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 12:38:31

Modified files:
	tools          : pvremove.c 
	.              : WHATS_NEW 

Log message:
	fix pvremove for pvs without mdas

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.938&r2=1.939

--- LVM2/tools/pvremove.c	2008/07/24 15:25:09	1.23
+++ LVM2/tools/pvremove.c	2008/07/31 12:38:31	1.24
@@ -25,18 +25,40 @@
 static int pvremove_check(struct cmd_context *cmd, const char *name)
 {
 	struct physical_volume *pv;
+	struct list mdas;
+
+	list_init(&mdas);
 
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {
+	if (!(pv = pv_read(cmd, name, &mdas, NULL, 1))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
 		log_error("Physical Volume %s not found", name);
 		return 0;
 	}
 
+	/*
+	 * If a PV has no MDAs it may appear to be an
+	 * orphan until the metadata is read off
+	 * another PV in the same VG.  Detecting this
+	 * means checking every VG by scanning every
+	 * PV on the system.
+	 */
+	if (is_orphan(pv) && !list_size(&mdas)) {
+		if (!scan_vgs_for_pvs(cmd)) {
+			log_error("Rescan for PVs without metadata areas "
+				  "failed.");
+			return 0;
+		}
+		if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {
+			log_error("Failed to read physical volume %s", name);
+			return 0;
+		}
+	}
+
 	/* orphan ? */
 	if (is_orphan(pv))
 		return 1;
--- LVM2/WHATS_NEW	2008/07/31 12:28:50	1.938
+++ LVM2/WHATS_NEW	2008/07/31 12:38:31	1.939
@@ -1,6 +1,6 @@
 Version 2.02.40 - 
 ================================
-  Fix pvchange to handle PVs without mdas.
+  Fix pvchange and pvremove to handle PVs without mdas.
   Refactor _text_pv_read and always return mda list if requested.
   Fix configure to work w/o readline unless --enable-readline used. (2.02.39)
   Remove is_lvm_partition template which has not yet been coded.


