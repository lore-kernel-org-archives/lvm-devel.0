From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 18:19:09 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090925181909.32662.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 18:19:09

Modified files:
	libdm          : libdm-common.c 

Log message:
	ensure dm_strdup succeeds

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/libdm/libdm-common.c	2009/09/25 18:13:17	1.83
+++ LVM2/libdm/libdm-common.c	2009/09/25 18:19:09	1.84
@@ -217,7 +217,9 @@
 			continue;
 
 		if (buf.st_rdev == st_rdev) {
-			new_name = dm_strdup(name);
+			if (!(new_name = dm_strdup(name)))
+				log_error("dm_task_set_name: strdup(%s) failed",
+					  name);
 			break;
 		}
 	}


