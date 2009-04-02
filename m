From: taka@sourceware.org <taka@sourceware.org>
Date: 2 Apr 2009 21:34:42 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c li ...
Message-ID: <20090402213442.10235.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-04-02 21:34:41

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c import_vsn1.c 
	lib/snapshot   : snapshot.c 

Log message:
	Save and restore the previous logging level when log level is changed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1075&r2=1.1076
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2009/04/02 20:46:11	1.1075
+++ LVM2/WHATS_NEW	2009/04/02 21:34:41	1.1076
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Save and restore the previous logging level when log level is changed.
   Fix error message when archive initialization fails.
   Make sure clvmd-corosync releases the lockspace when it exits.
   Fix segfault for vgcfgrestore on VG with missing PVs.
--- LVM2/lib/format_text/archiver.c	2009/03/24 13:16:35	1.21
+++ LVM2/lib/format_text/archiver.c	2009/04/02 21:34:41	1.22
@@ -397,6 +397,7 @@
 {
 	char path[PATH_MAX];
 	struct volume_group *vg_backup;
+	int old_suppress;
 
 	if (vg->status & EXPORTED_VG)
 		return;
@@ -407,15 +408,15 @@
 		return;
 	}
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 	/* Up-to-date backup exists? */
 	if ((vg_backup = backup_read_vg(vg->cmd, vg->name, path)) &&
 	    (vg->seqno == vg_backup->seqno) &&
 	    (id_equal(&vg->id, &vg_backup->id))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		return;
 	}
-	log_suppress(0);
+	log_suppress(old_suppress);
 
 	if (vg_backup)
 		archive(vg_backup);
--- LVM2/lib/format_text/import_vsn1.c	2009/03/09 15:42:12	1.56
+++ LVM2/lib/format_text/import_vsn1.c	2009/04/02 21:34:41	1.57
@@ -816,10 +816,11 @@
 {
 	const char *d;
 	unsigned int u = 0u;
+	int old_suppress;
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 	d = find_config_str(cft->root, "description", "");
-	log_suppress(0);
+	log_suppress(old_suppress);
 	*desc = dm_pool_strdup(mem, d);
 
 	get_config_uint32(cft->root, "creation_time", &u);
--- LVM2/lib/snapshot/snapshot.c	2009/02/28 20:04:25	1.35
+++ LVM2/lib/snapshot/snapshot.c	2009/04/02 21:34:41	1.36
@@ -37,6 +37,7 @@
 	uint32_t chunk_size;
 	const char *org_name, *cow_name;
 	struct logical_volume *org, *cow;
+	int old_suppress;
 
 	seg->lv->status |= SNAPSHOT;
 
@@ -45,21 +46,21 @@
 		return 0;
 	}
 
-	log_suppress(1);
+	old_suppress = log_suppress(1);
 
 	if (!(cow_name = find_config_str(sn, "cow_store", NULL))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		log_error("Snapshot cow storage not specified.");
 		return 0;
 	}
 
 	if (!(org_name = find_config_str(sn, "origin", NULL))) {
-		log_suppress(0);
+		log_suppress(old_suppress);
 		log_error("Snapshot origin not specified.");
 		return 0;
 	}
 
-	log_suppress(0);
+	log_suppress(old_suppress);
 
 	if (!(cow = find_lv(seg->lv->vg, cow_name))) {
 		log_error("Unknown logical volume specified for "


