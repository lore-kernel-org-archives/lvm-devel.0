From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Apr 2009 15:01:13 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090402150113.29177.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-02 15:01:12

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Allocate new pv->vg_name from pool, it can be destroyed later.
	
	(The mempool rename will be used later by vg private mempools)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208

--- LVM2/lib/metadata/metadata.c	2009/03/16 14:34:58	1.207
+++ LVM2/lib/metadata/metadata.c	2009/04/02 15:01:11	1.208
@@ -201,15 +201,17 @@
 static int _copy_pv(struct physical_volume *pv_to,
 		    struct physical_volume *pv_from)
 {
+	struct dm_pool *pvmem = pv_from->fmt->cmd->mem;
+
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
-	if (!str_list_dup(pv_to->fmt->cmd->mem, &pv_to->tags, &pv_from->tags)) {
-		log_error("PV tags duplication failed");
-		return 0;
-	}
+	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
+		return_0;
 
-	if (!peg_dup(pv_to->fmt->cmd->mem, &pv_to->segments,
-		     &pv_from->segments))
+	if (!str_list_dup(pvmem, &pv_to->tags, &pv_from->tags))
+		return_0;
+
+	if (!peg_dup(pvmem, &pv_to->segments, &pv_from->segments))
 		return_0;
 
 	return 1;
@@ -235,8 +237,10 @@
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&pvl->pv->id, (const struct id *) pvid)) {
-			if (!_copy_pv(pv, pvl->pv))
+			if (!_copy_pv(pv, pvl->pv)) {
+				log_error("internal PV duplication failed");
 				return_0;
+			}
 			return 1;
 		}
 	}


