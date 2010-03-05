From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2010 15:14:04 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20100305151404.28936.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-05 15:14:04

Modified files:
	lib/mm         : memlock.c 

Log message:
	Use '_' prefix for local static variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/mm/memlock.c	2010/03/05 14:48:34	1.16
+++ LVM2/lib/mm/memlock.c	2010/03/05 15:14:03	1.17
@@ -79,7 +79,7 @@
 	size_t w_size;
 	size_t x_size;
 };
-static struct maps_stats ms; /* statistic for maps locking */
+static struct maps_stats _ms; /* statistic for maps locking */
 
 static void _touch_memory(void *mem, size_t size)
 {
@@ -251,8 +251,8 @@
 {
 	_allocate_memory();
 
-	memset(&ms, 0, sizeof(ms));
-	if (_memlock_maps(cmd, LVM_MLOCK, &ms))
+	memset(&_ms, 0, sizeof(_ms));
+	if (_memlock_maps(cmd, LVM_MLOCK, &_ms))
 		log_very_verbose("Locking memory");
 
 	errno = 0;
@@ -271,9 +271,9 @@
 	if (_memlock_maps(cmd, LVM_MUNLOCK, &ums))
 		log_very_verbose("Unlocking memory");
 
-	if (memcmp(&ms, &ums, sizeof(ms)))
+	if (memcmp(&_ms, &ums, sizeof(ums)))
 		log_error(INTERNAL_ERROR "Maps size mismatch (%ld,%ld,%ld) != (%ld,%ld,%ld)",
-			  (long)ms.r_size,  (long)ms.w_size, (long)ms.x_size,
+			  (long)_ms.r_size, (long)_ms.w_size, (long)_ms.x_size,
 			  (long)ums.r_size, (long)ums.w_size, (long)ums.x_size);
 
 	_release_memory();


