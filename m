From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 21:32:45 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100629213245.19471.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 21:32:44

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : pvchange.c 

Log message:
	Move code into pv_change_metadataignore library function.
	
	In preparation to call this from both pvcreate as well as pvchange,
	move the guts of metadataignore into a library function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.158&r2=1.159
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.363&r2=1.364
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:40:01	1.158
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/29 21:32:44	1.159
@@ -866,6 +866,7 @@
 uint32_t pv_mda_count(const struct physical_volume *pv);
 uint32_t pv_mda_used_count(const struct physical_volume *pv);
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
+int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
 uint64_t lv_size(const struct logical_volume *lv);
 
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:40:01	1.363
+++ LVM2/lib/metadata/metadata.c	2010/06/29 21:32:44	1.364
@@ -4223,6 +4223,50 @@
 	return 0;
 }
 
+int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore)
+{
+	const char *pv_name = pv_dev_name(pv);
+
+	if (mda_ignore && (pv_mda_used_count(pv) == 0)) {
+		log_error("Physical volume \"%s\" metadata already "
+			  "ignored", pv_name);
+		return 0;
+	}
+	if (!mda_ignore && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
+		log_error("Physical volume \"%s\" metadata already "
+			  "not ignored", pv_name);
+		return 0;
+	}
+	if (!pv_mda_count(pv)) {
+		log_error("Physical volume \"%s\" has no metadata "
+			  "areas ", pv_name);
+		return 0;
+	}
+	if (mda_ignore) {
+		log_verbose("Setting physical volume \"%s\" "
+			    "metadata ignored", pv_name);
+	} else {
+		log_verbose("Setting physical volume \"%s\" "
+			    "metadata not ignored", pv_name);
+	}
+	if (!pv_mda_set_ignored(pv, mda_ignore)) {
+		return 0;
+	}
+	/*
+	 * Update vg_mda_copies based on the mdas in this PV.
+	 * This is most likely what the user would expect - if they
+	 * specify a specific PV to be ignored/un-ignored, they will
+	 * most likely not want LVM to turn around and change the
+	 * ignore / un-ignore value when it writes the VG to disk.
+	 * This does not guarantee this PV's ignore bits will be
+	 * preserved in future operations.
+	 */
+	if (!is_orphan(pv) && vg_mda_copies(pv->vg)) {
+		vg_set_mda_copies(pv->vg, vg_mda_used_count(pv->vg));
+	}
+	return 1;
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
--- LVM2/tools/pvchange.c	2010/06/28 20:38:06	1.78
+++ LVM2/tools/pvchange.c	2010/06/29 21:32:44	1.79
@@ -122,42 +122,8 @@
 			}
 		}
 	} else if (arg_count(cmd, metadataignore_ARG)) {
-		if (mda_ignore && (pv_mda_used_count(pv) == 0)) {
-			log_error("Physical volume \"%s\" metadata already "
-				  "ignored", pv_name);
+		if (!pv_change_metadataignore(pv, mda_ignore))
 			goto out;
-		}
-		if (!mda_ignore && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
-			log_error("Physical volume \"%s\" metadata already "
-				  "not ignored", pv_name);
-			goto out;
-		}
-		if (!pv_mda_count(pv)) {
-			log_error("Physical volume \"%s\" has no metadata "
-				  "areas ", pv_name);
-			goto out;
-		}
-		if (mda_ignore) {
-			log_verbose("Setting physical volume \"%s\" "
-				    "metadata ignored", pv_name);
-		} else {
-			log_verbose("Setting physical volume \"%s\" "
-				    "metadata not ignored", pv_name);
-		}
-		if (!pv_mda_set_ignored(pv, mda_ignore)) {
-			goto out;
-		}
-		/*
-		 * Update vg_mda_copies based on the mdas in this PV.
-		 * This is most likely what the user would expect - if they
-		 * specify a specific PV to be ignored/un-ignored, they will
-		 * most likely not want LVM to turn around and change the
-		 * ignore / un-ignore value when it writes the VG to disk.
-		 * This does not guarantee this PV's ignore bits will be
-		 * preserved in future operations.
-		 */
-		if (!is_orphan(pv) && vg_mda_copies(vg))
-			vg_set_mda_copies(vg, vg_mda_used_count(vg));
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {


