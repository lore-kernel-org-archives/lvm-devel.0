From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:19:28 -0000
Subject: LVM2 lib/metadata/lv_manip.c libdm/libdm-deptree.c
Message-ID: <20111028201928.31810.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:19:28

Modified files:
	lib/metadata   : lv_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Thin error messages clenaup and some indent

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.306&r2=1.307
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:18:32	1.306
+++ LVM2/lib/metadata/lv_manip.c	2011/10/28 20:19:26	1.307
@@ -3215,9 +3215,9 @@
 	if (lv_is_thin_pool(lv) && dm_list_size(&lv->segs_using_this_lv)) {
 		/* remove thin LVs first */
 		if ((force == PROMPT) &&
-		    yes_no_prompt("Do you really want to remove all thin volumes when removing "
-				  "pool logical volume %s? [y/n]: ", lv->name) == 'n') {
-			log_error("Logical volume %s not removed", lv->name);
+		    yes_no_prompt("Do you really want to remove all thin volumes when removing"
+				  " pool logical volume %s? [y/n]: ", lv->name) == 'n') {
+			log_error("Logical volume %s not removed.", lv->name);
 			return 0;
 		}
 		dm_list_iterate_safe(snh, snht, &lv->segs_using_this_lv) {
@@ -4308,7 +4308,7 @@
 		if (!seg_is_thin_pool(lp) &&
 		    !(lp->segtype = get_segtype_from_string(vg->cmd, "thin_pool")))
 			return_0;
-		
+
 		if (!(lv = _lv_create_an_lv(vg, lp, lp->pool)))
 			return_0;
 
@@ -4316,7 +4316,7 @@
 			goto out;
 
 		lp->pool = lv->name;
-	
+
 		if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))
 			return_0;
 	}
--- LVM2/libdm/libdm-deptree.c	2011/10/28 20:11:21	1.139
+++ LVM2/libdm/libdm-deptree.c	2011/10/28 20:19:26	1.140
@@ -1241,15 +1241,13 @@
 	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
 
 	if (type && (strcmp(type, "thin-pool") != 0)) {
-		log_error(INTERNAL_ERROR
-			  "Expected thin-pool target for %d:%d and got %s.",
+		log_error("Expected thin-pool target for %d:%d and got %s.",
 			  dnode->info.major, dnode->info.minor, type);
 		goto out;
 	}
 
 	if (!params || (sscanf(params, "%" PRIu64, transaction_id) != 1)) {
-		log_error(INTERNAL_ERROR
-			  "Failed to parse transaction_id from %s.", params);
+		log_error("Failed to parse transaction_id from %s.", params);
 		goto out;
 	}
 


