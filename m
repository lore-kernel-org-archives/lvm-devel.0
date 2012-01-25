From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 08:48:45 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20120125084845.22058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 08:48:43

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 

Log message:
	Thin add lv_thin_pool_transaction_id
	
	Easy function to get transaction_id status value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2236&r2=1.2237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.264&r2=1.265
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2012/01/24 14:33:38	1.2236
+++ LVM2/WHATS_NEW	2012/01/25 08:48:42	1.2237
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add lv_thin_pool_transaction_id to read the transaction_id value.
   Use suspend|resume_origin_only when up-converting RAID, as mirrors do.
   Fix the way RAID meta LVs are added to the dependency tree.
   Change exclusive LV activation logic to try local node before remote nodes.
--- LVM2/lib/activate/activate.c	2012/01/21 05:29:52	1.233
+++ LVM2/lib/activate/activate.c	2012/01/25 08:48:43	1.234
@@ -762,6 +762,35 @@
 	return r;
 }
 
+/*
+ * Returns 1 if transaction_id set, else 0 on failure.
+ */
+int lv_thin_pool_transaction_id(const struct logical_volume *lv,
+				uint64_t *transaction_id)
+{
+	int r;
+	struct dev_manager *dm;
+	struct dm_status_thin_pool *status;
+
+	if (!activation())
+		return 0;
+
+	log_debug("Checking thin percent for LV %s/%s",
+		  lv->vg->name, lv->name);
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!(r = dev_manager_thin_pool_status(dm, lv, &status)))
+		stack;
+	else
+		*transaction_id = status->transaction_id;
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 static int _lv_active(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct lvinfo info;
--- LVM2/lib/activate/activate.h	2012/01/20 00:27:19	1.94
+++ LVM2/lib/activate/activate.h	2012/01/25 08:48:43	1.95
@@ -105,6 +105,8 @@
 			 percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
 		    percent_t *percent);
+int lv_thin_pool_transaction_id(const struct logical_volume *lv,
+				uint64_t *transaction_id);
 
 /*
  * Return number of LVs in the VG that are active.
--- LVM2/lib/activate/dev_manager.c	2012/01/23 20:56:43	1.264
+++ LVM2/lib/activate/dev_manager.c	2012/01/25 08:48:43	1.265
@@ -882,6 +882,48 @@
 
 #endif
 
+int dev_manager_thin_pool_status(struct dev_manager *dm,
+				 const struct logical_volume *lv,
+				 struct dm_status_thin_pool **status)
+{
+	const char *dlid;
+	struct dm_task *dmt;
+	struct dm_info info;
+	uint64_t start, length;
+	char *type = NULL;
+	char *params = NULL;
+	int r = 0;
+
+	/* Build dlid for the thin pool layer */
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
+		return_0;
+
+	log_debug("Getting thin pool device status for %s.", lv->name);
+
+	if (!(dmt = _setup_task(NULL, dlid, 0, DM_DEVICE_STATUS, 0, 0)))
+		return_0;
+
+	if (!dm_task_no_open_count(dmt))
+		log_error("Failed to disable open_count.");
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto_out;
+
+	dm_get_next_target(dmt, NULL, &start, &length, &type, &params);
+
+	if (!dm_get_status_thin_pool(dm->mem, params, status))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
 				  int metadata, percent_t *percent)
--- LVM2/lib/activate/dev_manager.h	2012/01/19 15:27:54	1.44
+++ LVM2/lib/activate/dev_manager.h	2012/01/25 08:48:43	1.45
@@ -54,6 +54,9 @@
 int dev_manager_mirror_percent(struct dev_manager *dm,
 			       const struct logical_volume *lv, int wait,
 			       percent_t *percent, uint32_t *event_nr);
+int dev_manager_thin_pool_status(struct dev_manager *dm,
+				 const struct logical_volume *lv,
+				 struct dm_status_thin_pool **status);
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
 				  int metadata, percent_t *percent);


