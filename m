From: agk@sourceware.org <agk@sourceware.org>
Date: 15 May 2012 20:03:13 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20120515200313.7831.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-15 20:03:13

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	add major:minor to table size changed debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/libdm/libdm-deptree.c	2012/05/15 14:10:54	1.164
+++ LVM2/libdm/libdm-deptree.c	2012/05/15 20:03:12	1.165
@@ -2373,8 +2373,9 @@
 				dnode->props.size_changed = 0;
 
 			log_debug("Table size changed from %" PRIu64 " to %"
-				  PRIu64 " for %s.%s", existing_table_size,
-				  seg_start, dnode->name,
+				  PRIu64 " for %s (%" PRIu32 ":%" PRIu32 ").%s",
+				  existing_table_size, seg_start, dnode->name,
+				  dnode->info.major, dnode->info.minor,
 				  dnode->props.size_changed ? "" : " (Ignoring.)");
 		}
 	}


