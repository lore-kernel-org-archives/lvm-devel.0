From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 May 2009 12:58:05 -0000
Subject: LVM2/lib activate/activate.c locking/.exported ...
Message-ID: <20090520125805.17982.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-20 12:58:04

Modified files:
	lib/activate   : activate.c 
	lib/locking    : .exported_symbols external_locking.c locking.c 

Log message:
	Fix locking query compatibility with old external locking libraries.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/lib/activate/activate.c	2009/05/20 11:09:49	1.150
+++ LVM2/lib/activate/activate.c	2009/05/20 12:58:03	1.151
@@ -694,13 +694,30 @@
  */
 int lv_is_active(struct logical_volume *lv)
 {
+	int ret;
+
 	if (_lv_active(lv->vg->cmd, lv, 0))
 		return 1;
 
 	if (!vg_is_clustered(lv->vg))
 		return 0;
 
-	return remote_lock_held(lv->lvid.s);
+	if ((ret = remote_lock_held(lv->lvid.s)) >= 0)
+		return ret;
+
+	/*
+	 * Old compatibility code if locking doesn't support lock query
+	 * FIXME: check status to not deactivate already activate device
+	 */
+	if (activate_lv_excl(lv->vg->cmd, lv)) {
+		deactivate_lv(lv->vg->cmd, lv);
+			return 0;
+	}
+
+	/*
+	 * Exclusive local activation failed so assume it is active elsewhere.
+	 */
+	return 1;
 }
 
 /*
--- LVM2/lib/locking/.exported_symbols	2004/06/24 08:16:09	1.1
+++ LVM2/lib/locking/.exported_symbols	2009/05/20 12:58:04	1.2
@@ -1,4 +1,5 @@
 locking_init
 locking_end
 lock_resource
+lock_resource_query
 reset_locking
--- LVM2/lib/locking/external_locking.c	2008/01/30 13:59:59	1.15
+++ LVM2/lib/locking/external_locking.c	2009/05/20 12:58:04	1.16
@@ -26,6 +26,7 @@
 			uint32_t flags) = NULL;
 static int (*_init_fn) (int type, struct config_tree * cft,
 			uint32_t *flags) = NULL;
+static int (*_lock_query_fn) (const char *resource, int *mode) = NULL;
 
 static int _lock_resource(struct cmd_context *cmd, const char *resource,
 			  uint32_t flags)
@@ -88,6 +89,10 @@
 		return 0;
 	}
 
+	if (!(_lock_query_fn = dlsym(_locking_lib, "lock_resource_query")))
+		log_warn("WARNING: %s: _lock_resource_query() missing: "
+			 "Using inferior activation method.", libname);
+
 	log_verbose("Loaded external locking library %s", libname);
 	return _init_fn(2, cmd->cft, &locking->flags);
 }
--- LVM2/lib/locking/locking.c	2009/05/19 10:39:00	1.58
+++ LVM2/lib/locking/locking.c	2009/05/20 12:58:04	1.59
@@ -489,11 +489,13 @@
 	if (!locking_is_clustered())
 		return 0;
 
+	if (!_locking.lock_resource_query)
+		return -1;
+
 	/*
 	 * If an error occured, expect that volume is active
 	 */
-	if (!_locking.lock_resource_query ||
-	    !_locking.lock_resource_query(vol, &mode)) {
+	if (!_locking.lock_resource_query(vol, &mode)) {
 		stack;
 		return 1;
 	}


