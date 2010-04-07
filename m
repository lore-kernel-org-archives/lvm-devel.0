From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Apr 2010 21:25:10 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20100407212510.14174.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-07 21:25:09

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Issue a message if the new type of deactivation failure happens.
	If this can happen during 'normal' operations, I need to know.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/libdm/libdm-deptree.c	2010/04/07 20:04:42	1.73
+++ LVM2/libdm/libdm-deptree.c	2010/04/07 21:25:09	1.74
@@ -1051,6 +1051,9 @@
 			continue;
 
 		if (info.open_count) {
+			log_error("Unable to deactivate open %s (%" PRIu32
+				  ":%" PRIu32 ")", name, info.major,
+				  info.minor);
 			r = 0;
 			continue;
 		}


