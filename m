From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Mar 2008 22:51:28 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20080313225128.11485.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-13 22:51:27

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Const cleanups in find_* functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.158&r2=1.159

--- LVM2/lib/metadata/metadata-exported.h	2008/02/13 20:01:48	1.44
+++ LVM2/lib/metadata/metadata-exported.h	2008/03/13 22:51:24	1.45
@@ -428,14 +428,18 @@
 					   const char *layer_suffix);
 
 /* Find a PV within a given VG */
-struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name);
-pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id);
+struct pv_list *find_pv_in_vg(const struct volume_group *vg,
+			      const char *pv_name);
+pv_t *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+			    const struct id *id);
 
 /* Find an LV within a given VG */
-struct lv_list *find_lv_in_vg(struct volume_group *vg, const char *lv_name);
+struct lv_list *find_lv_in_vg(const struct volume_group *vg,
+			      const char *lv_name);
 
 /* FIXME Merge these functions with ones above */
-struct logical_volume *find_lv(struct volume_group *vg, const char *lv_name);
+struct logical_volume *find_lv(const struct volume_group *vg,
+			       const char *lv_name);
 struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 					const char *pv_name);
 
--- LVM2/lib/metadata/metadata.c	2008/02/13 20:01:48	1.158
+++ LVM2/lib/metadata/metadata.c	2008/03/13 22:51:24	1.159
@@ -58,10 +58,11 @@
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
 			 			const char *pv_name);
 
-static struct pv_list *_find_pv_in_vg(struct volume_group *vg, const char *pv_name);
+static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
+				      const char *pv_name);
 
-static struct physical_volume *_find_pv_in_vg_by_uuid(struct volume_group *vg,
-						      struct id *id);
+static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
+						      const struct id *id);
 
 unsigned long pe_align(void)
 {
@@ -851,12 +852,14 @@
 }
 
 /* FIXME: liblvm todo - make into function that returns handle */
-struct pv_list *find_pv_in_vg(struct volume_group *vg, const char *pv_name)
+struct pv_list *find_pv_in_vg(const struct volume_group *vg,
+			      const char *pv_name)
 {
 	return _find_pv_in_vg(vg, pv_name);
 }
 
-static struct pv_list *_find_pv_in_vg(struct volume_group *vg, const char *pv_name)
+static struct pv_list *_find_pv_in_vg(const struct volume_group *vg,
+				      const char *pv_name)
 {
 	struct pv_list *pvl;
 
@@ -890,14 +893,15 @@
  * Note
  *   FIXME - liblvm todo - make into function that takes VG handle
  */
-pv_t *find_pv_in_vg_by_uuid(struct volume_group *vg, struct id *id)
+pv_t *find_pv_in_vg_by_uuid(const struct volume_group *vg,
+			    const struct id *id)
 {
 	return _find_pv_in_vg_by_uuid(vg, id);
 }
 
 
-static struct physical_volume *_find_pv_in_vg_by_uuid(struct volume_group *vg,
-						      struct id *id)
+static struct physical_volume *_find_pv_in_vg_by_uuid(const struct volume_group *vg,
+						      const struct id *id)
 {
 	struct pv_list *pvl;
 
@@ -908,7 +912,8 @@
 	return NULL;
 }
 
-struct lv_list *find_lv_in_vg(struct volume_group *vg, const char *lv_name)
+struct lv_list *find_lv_in_vg(const struct volume_group *vg,
+			      const char *lv_name)
 {
 	struct lv_list *lvl;
 	const char *ptr;
@@ -938,7 +943,8 @@
 	return NULL;
 }
 
-struct logical_volume *find_lv(struct volume_group *vg, const char *lv_name)
+struct logical_volume *find_lv(const struct volume_group *vg,
+			       const char *lv_name)
 {
 	struct lv_list *lvl = find_lv_in_vg(vg, lv_name);
 	return lvl ? lvl->lv : NULL;


