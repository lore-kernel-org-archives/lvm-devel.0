From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Oct 2011 14:18:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/functions.c ...
Message-ID: <20111014141851.5132.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-14 14:18:50

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: functions.c 
	libdm/misc     : dm-log-userspace.h 

Log message:
	cmirrord now returns log name to kernel in CTR so it can be registered
	
	Version 2 of the userspace log protocol accepts return information during the
	DM_ULOG_CTR exchange.  The return information contains the name of the log
	device that is being used (if there is one).  The kernel can then register the
	device via 'dm_get_device'.  Amoung other things, this allows for userspace to
	assemble a correct dependency tree of devices - critical for LVM handling of
	suspend/resume calls.
	
	Also, update dm-log-userspace.h to match the kernel header associated with
	this protocol change.  (Includes a version inc.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2161&r2=1.2162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-log-userspace.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2011/10/14 13:23:47	1.2161
+++ LVM2/WHATS_NEW	2011/10/14 14:18:49	1.2162
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Log dev name now returned to kernel for registering during cmirror CTR.
   Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
   Simplify code for lvm worker thread in clvmd.                     
   Use pthread_barrier to synchronize clvmd threads at startup.
--- LVM2/daemons/cmirrord/functions.c	2011/09/21 10:42:53	1.29
+++ LVM2/daemons/cmirrord/functions.c	2011/10/14 14:18:49	1.30
@@ -597,7 +597,10 @@
 	/* We join the CPG when we resume */
 
 	/* No returning data */
-	rq->data_size = 0;
+	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk"))
+		rq->data_size = sprintf(rq->data, "%s", argv[1]) + 1;
+	else
+		rq->data_size = 0;
 
 	if (r) {
 		LOG_ERROR("Failed to create cluster log (%s)", rq->uuid);
--- LVM2/libdm/misc/dm-log-userspace.h	2011/10/14 14:04:05	1.4
+++ LVM2/libdm/misc/dm-log-userspace.h	2011/10/14 14:18:49	1.5
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


