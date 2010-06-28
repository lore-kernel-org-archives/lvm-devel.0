From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Jun 2010 14:19:53 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20100628141953.3420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-06-28 14:19:46

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix for bz608048 from Taka...
	
	The same region size is used for both mirror volume and mirrored
	log volume, but when the physical extent size is bigger than region size,
	the size of mirror leg for mirrored log is smaller than the region size
	and lvcreate command fails.
	
	This patch adjusts a region size of mirrored log to a smaller value of
	region size or physical extent size.
	
	[This patch ensures that the region_size of the mirrored log does not
	exceed the size of the mirrored log itself, which would violate the
	kernel constraint: (region_size <= ti->len).]
	
	Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1637&r2=1.1638
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2010/06/25 18:17:38	1.1637
+++ LVM2/WHATS_NEW	2010/06/28 14:19:41	1.1638
@@ -1,5 +1,6 @@
 Version 2.02.69 - 
 ================================
+  Ensure region_size of mirrored log does not exceed its full size.
   Generate liblvm2app and libdevmapper exported symbols from header file.
   Preload libc locale messages to prevent reading it in memory locked state.
   Fix handling of simultaneous mirror image and mirrored log image failure.
--- LVM2/lib/metadata/mirror.c	2010/06/23 13:57:26	1.120
+++ LVM2/lib/metadata/mirror.c	2010/06/28 14:19:45	1.121
@@ -1816,7 +1816,9 @@
 	 * create and initialize mirror log
 	 */
 	if (log_count &&
-	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
+	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
+					  (region_size > lv->vg->extent_size) ?
+					  lv->vg->extent_size : region_size,
 					  alloc, mirror_in_sync()))) {
 		stack;
 		goto out_remove_images;


