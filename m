From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 18:29:07 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdm-deptree.c
Message-ID: <20101123182907.29349.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 18:29:06

Modified files:
	.              : WHATS_NEW 
	libdm          : libdm-deptree.c 

Log message:
	Do not call dm_task_destroy with NULL

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1803&r2=1.1804
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2010/11/23 15:28:55	1.1803
+++ LVM2/WHATS_NEW	2010/11/23 18:29:06	1.1804
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix dm_task_destroy(NULL) call in _node_clear_table() error path.
   Fix resource leak in _rm_blks().
   Suppress 'No PV label' message when removing several PVs without mdas.
   Fix default /etc/lvm permissions to be 0755. (2.02.66)
--- LVM2/libdm/libdm-deptree.c	2010/09/30 21:06:52	1.86
+++ LVM2/libdm/libdm-deptree.c	2010/11/23 18:29:06	1.87
@@ -580,7 +580,6 @@
 		    name, info->major, info->minor);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CLEAR))) {
-		dm_task_destroy(dmt);
 		log_error("Table clear dm_task creation failed for %s", name);
 		return 0;
 	}


