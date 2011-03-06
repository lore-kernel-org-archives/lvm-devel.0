From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Mar 2011 16:47:44 -0000
Subject: LVM2 ./WHATS_NEW lib/mm/memlock.c
Message-ID: <20110306164744.13366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-06 16:47:43

Modified files:
	.              : WHATS_NEW 
	lib/mm         : memlock.c 

Log message:
	Fix hardcoded page size, fixing test fails with 8k page and new kernel.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1935&r2=1.1936
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2011/03/05 12:14:00	1.1935
+++ LVM2/WHATS_NEW	2011/03/06 16:47:43	1.1936
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Use system page size and not hardcoded value in locking code check.
   Fix reading of released memory for printing segment type.
   Fix syslog initialisation in clvmd to respect lvm.conf setting.
   Fix possible overflow in maximum stripe size and physical extent size.
--- LVM2/lib/mm/memlock.c	2011/02/18 14:51:04	1.35
+++ LVM2/lib/mm/memlock.c	2011/03/06 16:47:43	1.36
@@ -344,7 +344,7 @@
 		dm_free(_maps_buffer);
 		_maps_buffer = NULL;
 		if (_mstats < unlock_mstats) {
-			if ((_mstats + 4096) < unlock_mstats)
+			if ((_mstats + getpagesize()) < unlock_mstats)
 				log_error(INTERNAL_ERROR
 					  "Maps lock %ld < unlock %ld",
 					  (long)_mstats, (long)unlock_mstats);


