From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 12:05:46 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20101025120546.7620.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 12:05:46

Modified files:
	tools          : lvcreate.c 

Log message:
	Ensure we always have origin defined
	
	Reported by clang as: Logic error Dereference of null pointer
	Make sure the code path could not use NULL origin because of some internal
	code error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224

--- LVM2/tools/lvcreate.c	2010/07/09 15:34:48	1.223
+++ LVM2/tools/lvcreate.c	2010/10/25 12:05:46	1.224
@@ -179,6 +179,10 @@
 					  lp->origin);
 				return 0;
 			}
+			if (!origin) {
+				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
+				return 0;
+			}
 			lp->extents = lp->extents * origin->le_count / 100;
 			break;
 		case PERCENT_NONE:


