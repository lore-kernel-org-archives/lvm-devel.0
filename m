From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Mar 2011 17:52:08 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20110306175208.16985.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-06 17:52:08

Modified files:
	lib/mm         : memlock.c 

Log message:
	Use lvm_getpagesize wrapper

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/lib/mm/memlock.c	2011/03/06 16:47:43	1.36
+++ LVM2/lib/mm/memlock.c	2011/03/06 17:52:07	1.37
@@ -344,7 +344,7 @@
 		dm_free(_maps_buffer);
 		_maps_buffer = NULL;
 		if (_mstats < unlock_mstats) {
-			if ((_mstats + getpagesize()) < unlock_mstats)
+			if ((_mstats + lvm_getpagesize()) < unlock_mstats)
 				log_error(INTERNAL_ERROR
 					  "Maps lock %ld < unlock %ld",
 					  (long)_mstats, (long)unlock_mstats);


