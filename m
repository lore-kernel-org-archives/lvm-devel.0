From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 19:13:05 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20110708191305.25010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 19:13:05

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Downgrade error message - it isn't strictly an internal error in the
	library, and the known cause within lvm2 got fixed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/libdm/libdm-deptree.c	2011/06/30 09:24:58	1.101
+++ LVM2/libdm/libdm-deptree.c	2011/07/08 19:13:05	1.102
@@ -1754,10 +1754,12 @@
 			stack;
 			return r;
 		}
-		if (!params[0])
-			log_error(INTERNAL_ERROR "Empty parameters for "
-				  "%s %u:%u.", dm_segtypes[seg->type].target,
+		if (!params[0]) {
+			log_error("No parameters supplied for %s target "
+				  "%u:%u.", dm_segtypes[seg->type].target,
 				  major, minor);
+			return 0;
+		}
 		break;
 	}
 


