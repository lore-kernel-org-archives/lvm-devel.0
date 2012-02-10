From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 13:56:21 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-string.c
Message-ID: <20120210135621.27817.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 13:56:20

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-string.c 

Log message:
	Return error for failing allocation
	
	Fix case, where final strdup would have failed and it would miss to return
	failure for this case and return success and NULL pointer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.544&r2=1.545
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW_DM	2012/02/10 13:52:05	1.544
+++ LVM2/WHATS_NEW_DM	2012/02/10 13:56:19	1.545
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Return error for failing allocation in dm_asprintf().
   Add missing test for failing allocation in dm_realloc() code.
   Add test for memory allocation failures in regex matcher code.
   Simplify dm_task_set_geometry() and use dm_asprintf().
--- LVM2/libdm/libdm-string.c	2011/09/14 16:07:07	1.17
+++ LVM2/libdm/libdm-string.c	2012/02/10 13:56:20	1.18
@@ -156,7 +156,9 @@
 		}
 	}
 
-	*result = dm_strdup(buf);
+	if (!(*result = dm_strdup(buf)))
+		n = -2; /* return -1 */
+
 	dm_free(buf);
 	return n + 1;
 }


