From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 16:13:58 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-deptree.c
Message-ID: <20110218161358.31313.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 16:13:57

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-deptree.c 

Log message:
	Add debug message for open_count failure
	
	Report  open_count problem as debug.
	
	Function using _node_has_closed_parents decides whether
	it's error or could be ignored.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.447&r2=1.448
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/WHATS_NEW_DM	2011/02/18 14:38:47	1.447
+++ LVM2/WHATS_NEW_DM	2011/02/18 16:13:56	1.448
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Log debug open_count in _node_has_closed_parents().
   Change dm_report_field_string() API to accept const char *const *data.
 
 Version 1.02.63 - 9th February 2011
--- LVM2/libdm/libdm-deptree.c	2010/11/29 12:42:10	1.89
+++ LVM2/libdm/libdm-deptree.c	2011/02/18 16:13:56	1.90
@@ -938,8 +938,11 @@
 		    !info.exists)
 			continue;
 
-		if (info.open_count)
+		if (info.open_count) {
+			log_debug("Node %s %d:%d has open_count %d", uuid_prefix,
+				  dinfo->major, dinfo->minor, info.open_count);
 			return 0;
+		}
 	}
 
 	return 1;


