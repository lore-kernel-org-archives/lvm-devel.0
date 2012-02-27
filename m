From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:40:58 -0000
Subject: LVM2/lib/format_text import_vsn1.c
Message-ID: <20120227114058.29902.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:40:58

Modified files:
	lib/format_text: import_vsn1.c 

Log message:
	Just code move of hash initialization in front of function
	
	Make sure both hash tables are initialized before _read_sections() call.
	Presents no functional change (since PV scan phase was not adding LV hashes),
	but makes the code easier to handle mem failing case, and static analyzer is
	hapier as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/lib/format_text/import_vsn1.c	2012/02/23 13:11:09	1.101
+++ LVM2/lib/format_text/import_vsn1.c	2012/02/27 11:40:58	1.102
@@ -694,6 +694,24 @@
 	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN + 1)))
 		goto_bad;
 
+	/*
+	 * The pv hash memorises the pv section names -> pv
+	 * structures.
+	 */
+	if (!(pv_hash = dm_hash_create(64))) {
+		log_error("Couldn't create pv hash table.");
+		goto bad;
+	}
+
+	/*
+	 * The lv hash memorises the lv section names -> lv
+	 * structures.
+	 */
+	if (!(lv_hash = dm_hash_create(1024))) {
+		log_error("Couldn't create lv hash table.");
+		goto bad;
+	}
+
 	vgn = vgn->child;
 
 	if (dm_config_get_str(vgn, "system_id", &str)) {
@@ -752,15 +770,6 @@
 		vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 	}
 
-	/*
-	 * The pv hash memorises the pv section names -> pv
-	 * structures.
-	 */
-	if (!(pv_hash = dm_hash_create(64))) {
-		log_error("Couldn't create hash table.");
-		goto bad;
-	}
-
 	if (!_read_sections(fid, "physical_volumes", _read_pv, vg,
 			    vgn, pv_hash, lv_hash, 0, &scan_done_once)) {
 		log_error("Couldn't find all physical volumes for volume "
@@ -775,15 +784,6 @@
 		goto bad;
 	}
 
-	/*
-	 * The lv hash memorises the lv section names -> lv
-	 * structures.
-	 */
-	if (!(lv_hash = dm_hash_create(1024))) {
-		log_error("Couldn't create hash table.");
-		goto bad;
-	}
-
 	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg,
 			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "


