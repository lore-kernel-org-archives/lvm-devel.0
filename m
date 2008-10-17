From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Oct 2008 10:57:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20081017105716.30830.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-17 10:57:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Use temp table to set device size when converting mirrors.
	
	(Avoids having same mirror table loaded twice concurrently by first
	using a 'zero' table to set the size of the device so when mirror
	table is preloaded it doesn't have to be activated immediately.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.976&r2=1.977
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/WHATS_NEW	2008/10/17 10:50:14	1.976
+++ LVM2/WHATS_NEW	2008/10/17 10:57:14	1.977
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Use temp table to set device size when converting mirrors.
   In resume_mirror_images replace activate_lv with resume_lv as workaround.
   Avoid overwriting in-use on-disk text metadata by forgetting MDA_HEADER_SIZE.
   Fix snapshot monitoring library to not cancel monitoring invalid snapshot.
--- LVM2/lib/metadata/lv_manip.c	2008/09/29 09:59:10	1.156
+++ LVM2/lib/metadata/lv_manip.c	2008/10/17 10:57:15	1.157
@@ -2360,11 +2360,7 @@
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
 
-	if (!(segtype = get_segtype_from_string(cmd, "striped")))
-		return_NULL;
-
 	/* create an empty layer LV */
-
 	len = strlen(lv_where->name) + 32;
 	if (!(name = alloca(len))) {
 		log_error("layer name allocation failed. "
@@ -2384,12 +2380,43 @@
 		return NULL;
 	}
 
+	if (strstr(name, "_mimagetmp")) {
+		log_very_verbose("Creating transient 'zero' LV"
+				 " for Mirror -> mirror up-convert.");
+
+		segtype = get_segtype_from_string(cmd, "zero");
+
+		if (!lv_add_virtual_segment(layer_lv, 0, lv_where->le_count, segtype)) {
+			log_error("Creation of intermediate layer LV failed.");
+			return NULL;
+		}
+
+		if (!vg_write(lv_where->vg)) {
+			log_error("Failed to write intermediate VG metadata");
+			return NULL;
+		}
+
+		if (!vg_commit(lv_where->vg)) {
+			log_error("Failed to commit intermediate VG metadata");
+			vg_revert(lv_where->vg);
+			return NULL;
+		}
+
+		if (!activate_lv(cmd, layer_lv)) {
+			log_error("Failed to resume intermediate 'zero' LV, %s", name);
+			return NULL;
+		}
+	}
+
 	log_very_verbose("Inserting layer %s for %s",
 			 layer_lv->name, lv_where->name);
 
 	if (!_move_lv_segments(layer_lv, lv_where, 0, 0))
 		return_NULL;
 
+	if (!(segtype = get_segtype_from_string(cmd, "striped")))
+		return_NULL;
+
 	/* allocate a new linear segment */
 	if (!(mapseg = alloc_lv_segment(cmd->mem, segtype,
 					lv_where, 0, layer_lv->le_count,


