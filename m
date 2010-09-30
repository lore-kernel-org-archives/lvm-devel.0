From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 13:05:46 -0000
Subject: LVM2 include/.symlinks.in lib/Makefile.in lib/ ...
Message-ID: <20100930130546.20183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 13:05:45

Modified files:
	include        : .symlinks.in 
	lib            : Makefile.in 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Refactor metadata.[ch] into lv.[ch] for lv functions.
	
	This patch is similar to the other patches for pv and vg
	functionality, and separates lv functionality into separate
	files, concentrating on reporting fields and simple functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.167&r2=1.168
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.399&r2=1.400

--- LVM2/include/.symlinks.in	2010/09/30 13:05:20	1.5
+++ LVM2/include/.symlinks.in	2010/09/30 13:05:45	1.6
@@ -30,6 +30,7 @@
 @top_srcdir@/lib/locking/locking.h
 @top_srcdir@/lib/log/log.h
 @top_srcdir@/lib/log/lvm-logging.h
+ at top_srcdir@/lib/metadata/lv.h
 @top_srcdir@/lib/metadata/lv_alloc.h
 @top_srcdir@/lib/metadata/metadata.h
 @top_srcdir@/lib/metadata/metadata-exported.h
--- LVM2/lib/Makefile.in	2010/09/30 13:05:20	1.107
+++ LVM2/lib/Makefile.in	2010/09/30 13:05:45	1.108
@@ -73,6 +73,7 @@
 	locking/locking.c \
 	locking/no_locking.c \
 	log/log.c \
+	metadata/lv.c \
 	metadata/lv_manip.c \
 	metadata/merge.c \
 	metadata/metadata.c \
--- LVM2/lib/metadata/metadata-exported.h	2010/09/30 13:05:20	1.167
+++ LVM2/lib/metadata/metadata-exported.h	2010/09/30 13:05:45	1.168
@@ -24,6 +24,7 @@
 #include "uuid.h"
 #include "pv.h"
 #include "vg.h"
+#include "lv.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
@@ -291,33 +292,6 @@
 #define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
 
-struct logical_volume {
-	union lvid lvid;
-	char *name;
-
-	struct volume_group *vg;
-
-	uint64_t status;
-	alloc_policy_t alloc;
-	uint32_t read_ahead;
-	int32_t major;
-	int32_t minor;
-
-	uint64_t size;		/* Sectors */
-	uint32_t le_count;
-
-	uint32_t origin_count;
-	struct dm_list snapshot_segs;
-	struct lv_segment *snapshot;
-
-	struct replicator_device *rdevice;/* For replicator-devs, rimages, slogs - reference to rdevice */
-	struct dm_list rsites;	/* For replicators - all sites */
-
-	struct dm_list segments;
-	struct dm_list tags;
-	struct dm_list segs_using_this_lv;
-};
-
 struct pe_range {
 	struct dm_list list;
 	uint32_t start;		/* PEs */
@@ -744,7 +718,6 @@
 */
 int pv_change_metadataignore(struct physical_volume *pv, uint32_t mda_ignore);
 
-uint64_t lv_size(const struct logical_volume *lv);
 
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
--- LVM2/lib/metadata/metadata.c	2010/09/30 13:05:20	1.399
+++ LVM2/lib/metadata/metadata.c	2010/09/30 13:05:45	1.400
@@ -3921,11 +3921,6 @@
 	return 1;
 }
 
-uint64_t lv_size(const struct logical_volume *lv)
-{
-	return lv->size;
-}
-
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance


