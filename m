From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Oct 2011 14:18:08 -0000
Subject: LVM2/lib/activate activate.c activate.h dev_ma ...
Message-ID: <20111017141808.25567.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-17 14:18:07

Modified files:
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 

Log message:
	Drop messages from lvm app context
	
	(revert)
	Thinp target uses activation context.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.245&r2=1.246
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/lib/activate/activate.c	2011/10/06 14:55:40	1.217
+++ LVM2/lib/activate/activate.c	2011/10/17 14:18:07	1.218
@@ -1664,55 +1664,6 @@
 	return r;
 }
 
-#if 0
-// FIXME: Remove this - example of supported messages thin pool
-"create_thin %u", dev_id
-"create_snap %u", dev_id
-"delete %u", dev_id
-"trim %u %" PRIu64, dev_id, new_size_sec
-"set_transaction_id %" PRIu64 " %" PRIu64, cur_id, new_id
-#endif
-
-int lv_send_message(const struct logical_volume *lv, const char *msg_format, ...)
-{
-	va_list ap;
-	struct dev_manager *dm;
-	const size_t buf_size = 128;
-	char *buf = NULL;
-	int r = 0, pr;
-
-	if (!activation())
-		return 0;
-
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
-		return_0;
-
-	if (!(buf = dm_malloc(buf_size))) {
-		log_error("Failed to allocate message buffer.");
-		goto out;
-	}
-
-	va_start(ap, msg_format);
-	pr = vsnprintf(buf, buf_size, msg_format, ap);
-	va_end(ap);
-
-	if (pr < 0 || pr >= buf_size) {
-		log_error("Failed to create message in reserved buffer size "
-			  "%" PRIsize_t, buf_size);
-		goto out;
-	}
-
-	log_debug("Sending message '%s' to LV %s/%s", buf, lv->vg->name, lv->name);
-
-	if (!(r = dev_manager_send_message(dm, lv, buf)))
-		stack;
-out:
-	dm_free(buf);
-	dev_manager_destroy(dm);
-
-	return r;
-}
-
 /*
  * Does PV use VG somewhere in its construction?
  * Returns 1 on failure.
--- LVM2/lib/activate/activate.h	2011/10/06 14:55:40	1.83
+++ LVM2/lib/activate/activate.h	2011/10/17 14:18:07	1.84
@@ -71,8 +71,6 @@
 int lv_deactivate(struct cmd_context *cmd, const char *lvid_s);
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv);
-__attribute__ ((format(printf, 2, 3)))
-int lv_send_message(const struct logical_volume *lv, const char *msg_format, ...);
 
 /*
  * Returns 1 if info structure has been populated, else 0.
--- LVM2/lib/activate/dev_manager.c	2011/10/14 13:23:47	1.245
+++ LVM2/lib/activate/dev_manager.c	2011/10/17 14:18:07	1.246
@@ -876,34 +876,6 @@
 	return r;
 }
 
-/*
- * Send message
- */
-int dev_manager_send_message(struct dev_manager *dm, const struct logical_volume *lv, const char *message)
-{
-	const char *name;
-	struct dm_task *dmt;
-	int r = 0;
-
-	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
-		return_0;
-
-	if (!(dmt = _setup_task(name, NULL, NULL, DM_DEVICE_TARGET_MSG, 0, 0)))
-		return_0;
-
-	if (!dm_task_set_message(dmt, message))
-		goto_out;
-
-	if (!dm_task_run(dmt))
-		goto_out;
-
-	r = 1;
-out:
-	dm_task_destroy(dmt);
-
-	return r;
-}
-
 static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *lv,
 				const char *layer)
 {
--- LVM2/lib/activate/dev_manager.h	2011/10/03 18:37:48	1.39
+++ LVM2/lib/activate/dev_manager.h	2011/10/17 14:18:07	1.40
@@ -62,7 +62,6 @@
 int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
 int dev_manager_mknodes(const struct logical_volume *lv);
-int dev_manager_send_message(struct dev_manager *dm, const struct logical_volume *lv, const char *message);
 
 /*
  * Put the desired changes into effect.


