From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Jan 2008 20:42:58 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20080107204258.9766.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-01-07 20:42:57

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : reporter.c 

Log message:
	Fix a segfault if using pvs with --all argument. (2.02.29)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.751&r2=1.752
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2008/01/04 11:48:40	1.751
+++ LVM2/WHATS_NEW	2008/01/07 20:42:56	1.752
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Fix a segfault if using pvs with --all argument. (2.02.29)
   Update --uuid argument description in man pages.
   Fix vgreduce PV list processing not to process every PV in the VG. (2.02.29)
   Extend lvconvert to use polldaemon.
--- LVM2/lib/metadata/metadata-exported.h	2007/12/22 02:12:59	1.29
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/07 20:42:57	1.30
@@ -312,6 +312,7 @@
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
+int is_pv(pv_t *pv);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(pv_t *pv);
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
--- LVM2/lib/metadata/metadata.c	2007/12/20 18:55:46	1.145
+++ LVM2/lib/metadata/metadata.c	2008/01/07 20:42:57	1.146
@@ -1832,6 +1832,15 @@
 	return is_orphan_vg(pv_field(pv, vg_name));
 }
 
+/**
+ * is_pv - Determine whether a pv is a real pv or dummy one
+ * @pv: handle to device
+ */
+int is_pv(pv_t *pv)
+{
+	return (pv_field(pv, vg_name) ? 1 : 0);
+}
+
 /*
  * Returns:
  *  0 - fail
--- LVM2/tools/reporter.c	2007/12/20 16:49:37	1.32
+++ LVM2/tools/reporter.c	2008/01/07 20:42:57	1.33
@@ -91,7 +91,7 @@
 	int ret = ECMD_PROCESSED;
 	const char *vg_name = NULL;
 
-	if (!is_orphan(pv) && !vg) {
+	if (is_pv(pv) && !is_orphan(pv) && !vg) {
 		vg_name = pv_vg_name(pv);
 
 		if (!(vg = vg_lock_and_read(cmd, vg_name, (char *)&pv->vgid,


