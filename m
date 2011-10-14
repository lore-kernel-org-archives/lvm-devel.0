From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Oct 2011 14:04:06 -0000
Subject: LVM2/libdm/misc dm-log-userspace.h
Message-ID: <20111014140406.28798.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-14 14:04:06

Modified files:
	libdm/misc     : dm-log-userspace.h 

Log message:
	Update stale libdm/misc/dm-log-userspace.h
	
	The upstream kernel version that this file mirrors has changed, here is the
	commit message:
	
	commit 86a54a4802df10d23ccd655e2083e812fe990243
	Author: Jonathan Brassow <jbrassow@redhat.com>
	Date:   Thu Jan 13 19:59:52 2011 +0000
	
	dm log userspace: add version number to comms
	
	This patch adds a 'version' field to the 'dm_ulog_request'
	structure.
	
	The 'version' field is taken from a portion of the unused
	'padding' field in the 'dm_ulog_request' structure.  This
	was done to avoid changing the size of the structure and
	possibly disrupting backwards compatibility.
	
	The version number will help notify user-space daemons
	when a change has been made to the kernel/userspace
	log API.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>
	Signed-off-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-log-userspace.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdm/misc/dm-log-userspace.h	2010/06/22 13:11:32	1.3
+++ LVM2/libdm/misc/dm-log-userspace.h	2011/10/14 14:04:05	1.4
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
@@ -383,8 +393,9 @@
 	 */
 	uint64_t luid;
 	char uuid[DM_UUID_LEN];
-	char padding[7];        /* Padding because DM_UUID_LEN = 129 */
+	char padding[3];        /* Padding because DM_UUID_LEN = 129 */
 
+	uint32_t version;       /* See DM_ULOG_REQUEST_VERSION */
 	int32_t error;          /* Used to report back processing errors */
 
 	uint32_t seq;           /* Sequence number for request */


