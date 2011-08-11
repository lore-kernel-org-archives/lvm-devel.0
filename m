From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 17:24:25 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20110811172425.23087.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 17:24:24

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/metadata   : metadata.c vg.c vg.h 

Log message:
	Cache and share generated VG structs
	
	Extend vginfo cache with cached VG structure. So if the same metadata
	are use, skip mda decoding in the case, the same data are in use.
	This helps for operations like activation of all LVs in one VG,
	where same data were decoded giving the same output result.
	
	Patch adds 1-to-1 connection between volume_group and lvmcache_vginfo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2064&r2=1.2065
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.463&r2=1.464
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2011/08/11 16:31:40	1.2064
+++ LVM2/WHATS_NEW	2011/08/11 17:24:23	1.2065
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Cache and share generated VG structs.
   Fix possible format instance memory leaks and premature releases in _vg_read.
   Suppress locking error messages in monitoring init scripts.
   If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
--- LVM2/lib/cache/lvmcache.c	2011/08/10 20:25:30	1.113
+++ LVM2/lib/cache/lvmcache.c	2011/08/11 17:24:24	1.114
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -90,6 +90,8 @@
 	}
 
 	log_debug("Metadata cache: VG %s wiped.", vginfo->vgname);
+
+	release_vg(vginfo->cached_vg);
 }
 
 /*
@@ -662,6 +664,10 @@
 	    (!precommitted && vginfo->precommitted && !critical_section()))
 		return NULL;
 
+	/* Use already-cached VG struct when available */
+	if ((vg = vginfo->cached_vg))
+		goto out;
+
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vginfo->vgname;
 	fic.context.vg_ref.vg_id = vgid;
@@ -677,17 +683,44 @@
 	if (!(vg = import_vg_from_config_tree(vginfo->cft, fid)))
 		goto_bad;
 
-	log_debug("Using cached %smetadata for VG %s.",
-		  vginfo->precommitted ? "pre-committed" : "", vginfo->vgname);
+	/* Cache VG struct for reuse */
+	vginfo->cached_vg = vg;
+	vginfo->holders = 1;
+	vginfo->vg_use_count = 0;
+	vg->vginfo = vginfo;
+
+out:
+	vginfo->holders++;
+	vginfo->vg_use_count++;
+	log_debug("Using cached %smetadata for VG %s with %u holder(s).",
+		  vginfo->precommitted ? "pre-committed " : "",
+		  vginfo->vgname, vginfo->holders);
 
 	return vg;
 
 bad:
-	release_vg(vg);
 	_free_cached_vgmetadata(vginfo);
 	return NULL;
 }
 
+int vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo)
+{
+	log_debug("VG %s decrementing %d holder(s) at %p.",
+		  vginfo->cached_vg->name, vginfo->holders, vginfo->cached_vg);
+
+	if (--vginfo->holders)
+		return 0;
+
+	if (vginfo->vg_use_count > 1)
+		log_debug("VG %s reused %d times.",
+			  vginfo->cached_vg->name, vginfo->vg_use_count);
+
+	vginfo->cached_vg->vginfo = NULL;
+	vginfo->cached_vg = NULL;
+
+	return 1;
+}
+
 struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				   int include_internal)
 {
--- LVM2/lib/cache/lvmcache.h	2011/06/01 19:29:32	1.39
+++ LVM2/lib/cache/lvmcache.h	2011/08/11 17:24:24	1.40
@@ -50,6 +50,9 @@
 	char *vgmetadata;	/* Copy of VG metadata as format_text string */
 	struct config_tree *cft; /* Config tree created from vgmetadata */
 				/* Lifetime is directly tied to vgmetadata */
+	struct volume_group *cached_vg;
+	unsigned holders;
+	unsigned vg_use_count;	/* Counter of vg reusage */
 	unsigned precommitted;	/* Is vgmetadata live or precommitted? */
 };
 
@@ -93,6 +96,8 @@
 
 /* Queries */
 const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels);
+/* Decrement and test if there are still vg holders in vginfo. */
+int vginfo_holders_dec_and_test_for_zero(struct lvmcache_vginfo *vginfo);
 struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
--- LVM2/lib/metadata/metadata.c	2011/08/11 16:31:40	1.463
+++ LVM2/lib/metadata/metadata.c	2011/08/11 17:24:24	1.464
@@ -866,6 +866,12 @@
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
+	/* Never return a cached VG structure for a failure */
+	if (vg && vg->vginfo && failure != SUCCESS) {
+		release_vg(vg);
+		vg = NULL;
+	}
+
 	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
 		return_NULL;
 
--- LVM2/lib/metadata/vg.c	2011/08/10 20:25:30	1.11
+++ LVM2/lib/metadata/vg.c	2011/08/11 17:24:24	1.12
@@ -18,6 +18,7 @@
 #include "display.h"
 #include "activate.h"
 #include "toolcontext.h"
+#include "lvmcache.h"
 
 struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 			      const char *vg_name)
@@ -49,6 +50,8 @@
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
 
+	log_debug("Allocated VG %s at %p.", vg->name, vg);
+
 	return vg;
 }
 
@@ -62,6 +65,8 @@
 		return;
 	}
 
+	log_debug("Freeing VG %s at %p.", vg->name, vg);
+
 	dm_pool_destroy(vg->vgmem);
 }
 
@@ -70,6 +75,11 @@
 	if (!vg)
 		return;
 
+	/* Check if there are any vginfo holders */
+	if (vg->vginfo &&
+	    !vginfo_holders_dec_and_test_for_zero(vg->vginfo))
+		return;
+
 	_free_vg(vg);
 }
 
--- LVM2/lib/metadata/vg.h	2011/08/10 20:26:41	1.14
+++ LVM2/lib/metadata/vg.h	2011/08/11 17:24:24	1.15
@@ -41,6 +41,7 @@
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
 	struct format_instance *fid;
+	struct lvmcache_vginfo *vginfo;
 	struct dm_list *cmd_vgs;/* List of wanted/locked and opened VGs */
 	uint32_t cmd_missing_vgs;/* Flag marks missing VG */
 	uint32_t seqno;		/* Metadata sequence number */


