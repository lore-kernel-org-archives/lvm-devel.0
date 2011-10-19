From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:32:35 -0000
Subject: LVM2/lib/metadata thin_manip.c
Message-ID: <20111019163235.3870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:32:34

Modified files:
	lib/metadata   : thin_manip.c 

Log message:
	Remove test for thin_pool
	
	Since both functions are called during mda read - we don't have full LV info
	at this moment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/metadata/thin_manip.c	2011/10/17 14:17:09	1.7
+++ LVM2/lib/metadata/thin_manip.c	2011/10/19 16:32:34	1.8
@@ -38,12 +38,6 @@
 
 int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv)
 {
-	if (!lv_is_thin_pool(pool_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not a thin pool",
-			  pool_lv->name);
-		return 0;
-	}
-
 	seg->pool_lv = pool_lv;
 	seg->lv->status |= THIN_VOLUME;
 
@@ -72,12 +66,6 @@
 {
 	struct lv_thin_message *tmsg;
 
-	if (!lv_is_thin_pool(seg->lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not a thin pool.",
-			  seg->lv->name);
-		return 0;
-	}
-
 	if (!(tmsg = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*tmsg)))) {
 		log_error("Failed to allocate memory for message.");
 		return 0;


