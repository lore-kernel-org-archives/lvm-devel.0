From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:42:04 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20111118194204.15050.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:42:04

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Drop pool memory allocated in lv_has_target_type
	
	Remove FIXMES - there should not be any pool free call since
	the memory pool is from device manager, and pool is detroyed
	after the operation, so doing extra free here would not help here.
	
	However lv_has_target_type() is using cmd mempool so here the extra
	call for dm_pool_free makes sence.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2191&r2=1.2192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.251&r2=1.252

--- LVM2/WHATS_NEW	2011/11/18 19:31:09	1.2191
+++ LVM2/WHATS_NEW	2011/11/18 19:42:03	1.2192
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Drop pool memory allocated within lv_has_target_type().
   Reduce stack allocation of some PATH_MAX sized char buffers.
   Unlock memory before writing metadata.
   Add query before removing snapshots when inactive snapshot origin is removed.
--- LVM2/lib/activate/dev_manager.c	2011/11/15 17:25:05	1.251
+++ LVM2/lib/activate/dev_manager.c	2011/11/18 19:42:03	1.252
@@ -411,7 +411,7 @@
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
 				DM_DEVICE_STATUS, 0, 0)))
-		return_0;
+		goto_bad;
 
 	if (!dm_task_no_open_count(dmt))
 		log_error("Failed to disable open_count");
@@ -433,8 +433,11 @@
 		}
 	} while (next);
 
- out:
+out:
 	dm_task_destroy(dmt);
+bad:
+	dm_pool_free(mem, dlid);
+
 	return r;
 }
 
@@ -737,8 +740,6 @@
 		       NULL, fail_if_percent_unsupported)))
 		return_0;
 
-	/* FIXME dm_pool_free ? */
-
 	/* If the snapshot isn't available, percent will be -1 */
 	return 1;
 }
@@ -760,8 +761,6 @@
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
-	/* FIXME dm_pool_free ? */
-
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;


