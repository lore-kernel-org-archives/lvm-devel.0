From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jun 2007 15:48:05 -0000
Subject: LVM2 tools/pvremove.c tools/pvcreate.c lib/met ...
Message-ID: <20070614154805.5396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-06-14 15:48:05

Modified files:
	tools          : pvremove.c pvcreate.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	convert pv->vg_name[0] to \!is_orphan(pv)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.161&r2=1.162

--- LVM2/tools/pvremove.c	2007/06/14 15:25:36	1.14
+++ LVM2/tools/pvremove.c	2007/06/14 15:48:04	1.15
@@ -43,7 +43,7 @@
 	}
 
 	/* orphan ? */
-	if (!pv->vg_name[0])
+	if (!is_orphan(pv))
 		return 1;
 
 	/* Allow partial & exported VGs to be destroyed. */
@@ -64,9 +64,9 @@
 	if (arg_count(cmd, force_ARG)) {
 		log_print("WARNING: Wiping physical volume label from "
 			  "%s%s%s%s", name,
-			  pv->vg_name[0] ? " of volume group \"" : "",
-			  pv->vg_name[0] ? get_pv_vg_name(pv) : "",
-			  pv->vg_name[0] ? "\"" : "");
+			  !is_orphan(pv) ? " of volume group \"" : "",
+			  !is_orphan(pv) ? get_pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? "\"" : "");
 	}
 
 	return 1;
--- LVM2/tools/pvcreate.c	2007/06/13 23:53:38	1.50
+++ LVM2/tools/pvcreate.c	2007/06/14 15:48:04	1.51
@@ -45,14 +45,14 @@
 
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
-	if (pv && pv->vg_name[0] && arg_count(cmd, force_ARG) != 2) {
+	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG) != 2) {
 		log_error("Can't initialize physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, get_pv_vg_name(pv));
 		return 0;
 	}
 
 	/* prompt */
-	if (pv && pv->vg_name[0] && !arg_count(cmd, yes_ARG) &&
+	if (pv && !is_orphan(pv) && !arg_count(cmd, yes_ARG) &&
 	    yes_no_prompt(_really_init, name, get_pv_vg_name(pv)) == 'n') {
 		log_print("%s: physical volume not initialized", name);
 		return 0;
@@ -103,12 +103,12 @@
 		}
 	}
 
-	if (pv && pv->vg_name[0] && arg_count(cmd, force_ARG)) {
+	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG)) {
 		log_print("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
-			  pv->vg_name[0] ? " of volume group \"" : "",
-			  pv->vg_name[0] ? pv->vg_name : "",
-			  pv->vg_name[0] ? "\"" : "");
+			  !is_orphan(pv) ? " of volume group \"" : "",
+			  !is_orphan(pv) ? get_pv_vg_name(pv) : "",
+			  !is_orphan(pv) ? "\"" : "");
 	}
 
 	return 1;
--- LVM2/lib/metadata/metadata.c	2007/06/13 21:14:07	1.116
+++ LVM2/lib/metadata/metadata.c	2007/06/14 15:48:05	1.117
@@ -1687,6 +1687,17 @@
 
 	return 1;
 }
+
+/**
+ * is_orphan - Determine whether a pv is an orphan based on its vg_name
+ * @pv: handle to the physical volume
+ */
+int is_orphan(pv_t *pv)
+{
+	return (pv_field(pv, vg_name)[0] ? 0 : 1);
+}
+
+
 /*
  * Returns:
  *  0 - fail
--- LVM2/lib/metadata/metadata.h	2007/06/13 20:55:56	1.161
+++ LVM2/lib/metadata/metadata.h	2007/06/14 15:48:05	1.162
@@ -436,6 +436,7 @@
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
 int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
+int is_orphan(pv_t *pv);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
  * areas can avoid overlap */


