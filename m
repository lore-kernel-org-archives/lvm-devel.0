From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2007 17:40:40 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirror.c
Message-ID: <20070123174040.28112.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-23 17:40:40

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 

Log message:
	Add private variable to dmeventd shared library interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.553&r2=1.554
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2007/01/23 16:03:53	1.553
+++ LVM2/WHATS_NEW	2007/01/23 17:40:40	1.554
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Add private variable to dmeventd shared library interface.
   Long-lived processes write out persistent dev cache in refresh_toolcontext().
   Fix refresh_toolcontext() always to wipe persistent device filter cache.
   Add is_long_lived to toolcontext.
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/15 18:22:01	1.15
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/23 17:40:40	1.16
@@ -164,7 +164,8 @@
 	return (r == 1) ? 0 : -1;
 }
 
-void process_event(struct dm_task *dmt, enum dm_event_mask event)
+void process_event(struct dm_task *dmt, enum dm_event_mask event,
+		   void **unused __attribute((unused)))
 {
 	void *next = NULL;
 	uint64_t start, length;
@@ -221,7 +222,8 @@
 	pthread_mutex_unlock(&_event_mutex);
 }
 
-int register_device(const char *device, const char *uuid, int major, int minor)
+int register_device(const char *device, const char *uuid, int major, int minor,
+		   void **unused __attribute((unused)))
 {
 	int r = 0;
 
@@ -257,7 +259,8 @@
 	return r;
 }
 
-int unregister_device(const char *device, const char *uuid, int major, int minor)
+int unregister_device(const char *device, const char *uuid, int major, int minor,
+		   void **unused __attribute((unused)))
 {
 	pthread_mutex_lock(&_register_mutex);
 


