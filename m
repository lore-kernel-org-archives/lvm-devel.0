From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:32:45 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20101130223245.11604.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:32:45

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add error path stack traces
	
	Check for errors from dm_task_set_name() and dm_task_run().
	Add stack traces for error paths.
	Return 0 if some error is found.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/libdm/ioctl/libdm-iface.c	2010/10/25 11:44:20	1.83
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/11/30 22:32:44	1.84
@@ -1594,8 +1594,15 @@
 		    !strcmp(dirent->d_name, "..") ||
 		    !strcmp(dirent->d_name, "control"))
 			continue;
-		dm_task_set_name(dmt, dirent->d_name);
-		dm_task_run(dmt);
+		if (!dm_task_set_name(dmt, dirent->d_name)) {
+			r = 0;
+			stack;
+			continue; /* try next name */
+		}
+		if (!dm_task_run(dmt)) {
+			r = 0;
+			stack;  /* keep going */
+		}
 	}
 
 	if (closedir(d))


