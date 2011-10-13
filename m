From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 13 Oct 2011 14:24:39 -0500
Subject: [PATCH] LVM cmirrord: Pass device name to kernel in CTR operation
Message-ID: <1318533879.28595.13.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Make cmirrord return device information to kernel in CTR so they can be registered

Also, update dm-log-userspace to the latest upstream version.

Index: LVM2/daemons/cmirrord/functions.c
===================================================================
--- LVM2.orig/daemons/cmirrord/functions.c
+++ LVM2/daemons/cmirrord/functions.c
@@ -597,7 +597,10 @@ static int clog_ctr(struct dm_ulog_reque
 	/* We join the CPG when we resume */
 
 	/* No returning data */
-	rq->data_size = 0;
+	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk"))
+		rq->data_size = sprintf(rq->data, "%s", argv[1]) + 1;
+	else
+		rq->data_size = 0;
 
 	if (r) {
 		LOG_ERROR("Failed to create cluster log (%s)", rq->uuid);
Index: LVM2/libdm/misc/dm-log-userspace.h
===================================================================
--- LVM2.orig/libdm/misc/dm-log-userspace.h
+++ LVM2/libdm/misc/dm-log-userspace.h
@@ -52,15 +52,20 @@
  * Payload-to-userspace:
  *	A single string containing all the argv arguments separated by ' 's
  * Payload-to-kernel:
- *	None.  ('data_size' in the dm_ulog_request struct should be 0.)
+ *	The name of the device that is used as the backing store for the log
+ *      data.  'dm_get_device' will be called on this device.  ('dm_put_device'
+ *      will be called on this device automatically after calling DM_ULOG_DTR.)
+ *      If there is no device needed for log data, 'data_size' in the
+ *      dm_ulog_request struct should be 0.
  *
  * The UUID contained in the dm_ulog_request structure is the reference that
  * will be used by all request types to a specific log.  The constructor must
- * record this assotiation with instance created.
+ * record this assotiation with the instance created.
  *
  * When the request has been processed, user-space must return the
- * dm_ulog_request to the kernel - setting the 'error' field and
- * 'data_size' appropriately.
+ * dm_ulog_request to the kernel - setting the 'error' field, filling the
+ * data field with the log device if necessary, and setting 'data_size'
+ * appropriately.
  */
 #define DM_ULOG_CTR                    1
 
@@ -377,8 +382,11 @@
  * dm_ulog_request or a change in the way requests are
  * issued/handled.  Changes are outlined here:
  *	version 1:  Initial implementation
+ *	version 2:  DM_ULOG_CTR allowed to return a string containing a
+ *	            device name that is to be registered with DM via
+ *	            'dm_get_device'.
  */
-#define DM_ULOG_REQUEST_VERSION 1
+#define DM_ULOG_REQUEST_VERSION 2
 
 struct dm_ulog_request {
 	/*



