From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:09:34 -0000
Subject: LVM2/lib/activate dev_manager.c dev_manager.h
Message-ID: <20111221130934.12020.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:09:34

Modified files:
	lib/activate   : dev_manager.c dev_manager.h 

Log message:
	Thin add dev_manager_thin_pool_percent
	
	dev manager function to read percent info from thin pool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.255&r2=1.256
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/activate/dev_manager.c	2011/12/21 12:59:22	1.255
+++ LVM2/lib/activate/dev_manager.c	2011/12/21 13:09:33	1.256
@@ -872,6 +872,30 @@
 
 #endif
 
+int dev_manager_thin_pool_percent(struct dev_manager *dm,
+				  const struct logical_volume *lv,
+				  percent_t *percent)
+{
+	char *name;
+	const char *dlid;
+
+	/*
+	 * Build a name for the top layer.
+	 */
+	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, thin_layer)))
+		return_0;
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, thin_layer)))
+		return_0;
+
+	log_debug("Getting device status percentage for %s", name);
+	if (!(_percent(dm, name, dlid, "thin-pool", 0, NULL, percent,
+		       NULL, 1)))
+		return_0;
+
+	return 1;
+}
+
 /*************************/
 /*  NEW CODE STARTS HERE */
 /*************************/
--- LVM2/lib/activate/dev_manager.h	2011/10/17 14:18:07	1.40
+++ LVM2/lib/activate/dev_manager.h	2011/12/21 13:09:34	1.41
@@ -52,6 +52,9 @@
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
 			       percent_t *percent, uint32_t *event_nr);
+int dev_manager_thin_pool_percent(struct dev_manager *dm,
+				  const struct logical_volume *lv,
+				  percent_t *percent);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,


