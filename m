From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Oct 2011 22:00:58 -0000
Subject: LVM2/lib metadata/lv_manip.c metadata/thin_man ...
Message-ID: <20111030220058.4648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-30 22:00:58

Modified files:
	lib/metadata   : lv_manip.c thin_manip.c 
	lib/thin       : thin.c 

Log message:
	Thin cleanups
	
	Fix/cleanup several error messages.
	Remove test for seg_is_thin which could never be true there.
	Replace (1<<24) with predefined constant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.312&r2=1.313
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/lib/metadata/lv_manip.c	2011/10/28 20:32:54	1.312
+++ LVM2/lib/metadata/lv_manip.c	2011/10/30 22:00:57	1.313
@@ -4206,7 +4206,7 @@
 		   (lp->activate == CHANGE_AE && !activate_lv_excl(cmd, lv)) ||
 		   (lp->activate == CHANGE_ALY && !activate_lv_local(cmd, lv))) {
 		log_error("Failed to activate new LV.");
-		if (lp->zero && !seg_is_thin(lp))
+		if (lp->zero)
 			goto deactivate_and_revert_new_lv;
 		return NULL;
 	}
--- LVM2/lib/metadata/thin_manip.c	2011/10/28 20:32:54	1.14
+++ LVM2/lib/metadata/thin_manip.c	2011/10/30 22:00:57	1.15
@@ -197,7 +197,8 @@
 	struct dm_list *h;
 
 	if (!seg_is_thin_pool(thin_pool_seg)) {
-		log_error("Segment in %s is not a thin pool segment.",
+		log_error(INTERNAL_ERROR
+			  "Segment in %s is not a thin pool segment.",
 			  thin_pool_seg->lv->name);
 		return 0;
 	}
@@ -208,9 +209,9 @@
 			max_id = dev_id;
 	}
 
-	if (++max_id >= (1 << 24)) {
+	if (++max_id > DM_THIN_MAX_DEVICE_ID) {
 		// FIXME: try to find empty holes....
-		log_error("Free device_id exhausted...");
+		log_error("Cannot find free device_id.");
 		return 0;
 	}
 
@@ -228,8 +229,9 @@
 	const size_t len = strlen(pool_lv->name) + 16;
 	char name[len];
 
-	if (lv_is_thin_pool(pool_lv)) {
-		log_error("Resize of pool %s not yet implemented.", pool_lv->name);
+	if (pool_lv->le_count) {
+		/* FIXME move code for manipulation from lv_manip.c */
+		log_error(INTERNAL_ERROR "Pool %s has already extents.", pool_lv->name);
 		return 0;
 	}
 
@@ -276,7 +278,7 @@
 			return 0;
 		}
 	} else {
-		log_error("Pool %s created without initilization.", pool_lv->name);
+		log_warn("WARNING: Pool %s is created without initilization.", pool_lv->name);
 	}
 
 	if (dm_snprintf(name, len, "%s_tmeta", pool_lv->name) < 0)
--- LVM2/lib/thin/thin.c	2011/10/28 20:25:08	1.26
+++ LVM2/lib/thin/thin.c	2011/10/30 22:00:58	1.27
@@ -252,7 +252,7 @@
 			dmsg.u.m_create_snap.origin_id = 0;//first_seg(first_seg(lmsg->u.lv)->origin)->device_id;
 			if (!dm_tree_node_add_thin_pool_message(node, &dmsg))
 				return_0;
-			log_error("Sorry SNAPSHOTS is not yet supported.");
+			log_error("Sorry SNAPSHOT is not yet supported.");
 			return 0;
 		case DM_THIN_MESSAGE_CREATE_THIN:
 			log_debug("Thin pool create_thin %s.", lmsg->u.lv->name);
@@ -268,7 +268,7 @@
 			break;
 		case DM_THIN_MESSAGE_TRIM:
 			/* FIXME: to be implemented */
-			log_error("Sorry TRIM is not yes supported.");
+			log_error("Sorry TRIM is not yet supported.");
 			return 0;
 		default:
 			log_error(INTERNAL_ERROR "Unsupported message.");
@@ -346,7 +346,7 @@
 
 #ifdef DEVMAPPER_SUPPORT
 static int _thin_add_target_line(struct dev_manager *dm,
-				 struct dm_pool *mem __attribute__((unused)),
+				 struct dm_pool *mem,
 				 struct cmd_context *cmd __attribute__((unused)),
 				 void **target_state __attribute__((unused)),
 				 struct lv_segment *seg,


