From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 13 Oct 2011 14:23:15 -0500
Subject: [PATCH] LVM: Update stale libdm/misc/dm-log-userspace.h file
Message-ID: <1318533795.28595.11.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

libdm/misc/dm-log-userspace.h has become stale - update it.

Index: LVM2/libdm/misc/dm-log-userspace.h
===================================================================
--- LVM2.orig/libdm/misc/dm-log-userspace.h
+++ LVM2/libdm/misc/dm-log-userspace.h
@@ -7,7 +7,7 @@
 #ifndef __DM_LOG_USERSPACE_H__
 #define __DM_LOG_USERSPACE_H__
 
-#include "dm-ioctl.h" /* For DM_UUID_LEN */
+#include <linux/dm-ioctl.h> /* For DM_UUID_LEN */
 
 /*
  * The device-mapper userspace log module consists of a kernel component and
@@ -363,13 +363,23 @@
  * various request types above.  The remaining 24-bits are currently
  * set to zero and are reserved for future use and compatibility concerns.
  *
- * User-space should always use DM_ULOG_REQUEST_TYPE to aquire the
+ * User-space should always use DM_ULOG_REQUEST_TYPE to acquire the
  * request type from the 'request_type' field to maintain forward compatibility.
  */
 #define DM_ULOG_REQUEST_MASK 0xFF
 #define DM_ULOG_REQUEST_TYPE(request_type) \
 	(DM_ULOG_REQUEST_MASK & (request_type))
 
+/*
+ * DM_ULOG_REQUEST_VERSION is incremented when there is a
+ * change to the way information is passed between kernel
+ * and userspace.  This could be a structure change of
+ * dm_ulog_request or a change in the way requests are
+ * issued/handled.  Changes are outlined here:
+ *	version 1:  Initial implementation
+ */
+#define DM_ULOG_REQUEST_VERSION 1
+
 struct dm_ulog_request {
 	/*
 	 * The local unique identifier (luid) and the universally unique
@@ -383,15 +393,16 @@ struct dm_ulog_request {
 	 */
 	uint64_t luid;
 	char uuid[DM_UUID_LEN];
-	char padding[7];        /* Padding because DM_UUID_LEN = 129 */
+	char padding[3];        /* Padding because DM_UUID_LEN = 129 */
 
+	uint32_t version;       /* See DM_ULOG_REQUEST_VERSION */
 	int32_t error;          /* Used to report back processing errors */
 
 	uint32_t seq;           /* Sequence number for request */
 	uint32_t request_type;  /* DM_ULOG_* defined above */
 	uint32_t data_size;     /* How much data (not including this struct) */
 
-	char data[];
+	char data[0];
 };
 
 #endif /* __DM_LOG_USERSPACE_H__ */



