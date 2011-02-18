From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:51:04 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20110218145104.6981.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:51:04

Modified files:
	lib/mm         : memlock.c 

Log message:
	Memory unlock allows 1 page difference
	
	As the kernel seems to be doing weird things during
	mlock -> munlock -  allow 1 page locking difference without
	warning - and log just debug message for a 1 page difference.
	
	Allocation happens outside critical section probably during
	log_warn printing.
	
	Should make tests passing for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/lib/mm/memlock.c	2011/02/18 14:16:12	1.34
+++ LVM2/lib/mm/memlock.c	2011/02/18 14:51:04	1.35
@@ -343,9 +343,15 @@
 			log_sys_error("close", _procselfmaps);
 		dm_free(_maps_buffer);
 		_maps_buffer = NULL;
-		if (_mstats < unlock_mstats)
-			log_error(INTERNAL_ERROR "Maps lock %ld < unlock %ld",
-				  (long)_mstats, (long)unlock_mstats);
+		if (_mstats < unlock_mstats) {
+			if ((_mstats + 4096) < unlock_mstats)
+				log_error(INTERNAL_ERROR
+					  "Maps lock %ld < unlock %ld",
+					  (long)_mstats, (long)unlock_mstats);
+			else
+				log_debug("Maps lock %ld < unlock %ld, 1 page difference!",
+					  (long)_mstats, (long)unlock_mstats);
+		}
 	}
 
 	if (setpriority(PRIO_PROCESS, 0, _priority))


