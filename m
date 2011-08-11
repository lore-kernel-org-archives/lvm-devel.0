From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 20:49:34 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110811204934.6761.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 20:49:33

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix memleak of geometry buffer
	
	Looks like this function is not used too often - thus leak was discovered
	by static analyzis (Coverity).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.489&r2=1.490
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW_DM	2011/08/11 17:29:04	1.489
+++ LVM2/WHATS_NEW_DM	2011/08/11 20:49:33	1.490
@@ -1,5 +1,6 @@
 Version 1.02.66 - 
 ===============================
+  Release geometry buffer in dm_task_destroy.
   Add memory pool locking functions to aid debuging of shared VG structs.
   Remove dev name prefix from dmsetup line output if major and minor is used.
   Remove support for the original version 1 dm ioctls.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/08/09 17:56:48	1.115
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/08/11 20:49:33	1.116
@@ -451,6 +451,7 @@
 	dm_free(dmt->dev_name);
 	dm_free(dmt->newname);
 	dm_free(dmt->message);
+	dm_free(dmt->geometry);
 	dm_free(dmt->uuid);
 	dm_free(dmt);
 }


