From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Sep 2011 09:51:37 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in
Message-ID: <20110923095137.20944.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-23 09:51:37

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 

Log message:
	Update dmsetup man page
	
	While dmsetup command properly shows all dmsetup resume supported options,
	man page missed to document it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.505&r2=1.506
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW_DM	2011/09/23 09:48:21	1.505
+++ LVM2/WHATS_NEW_DM	2011/09/23 09:51:37	1.506
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Update dmsetup resume man with --addnodeonresume/create options.
   Add dependency for dm man pages to man subdirectory make target all:.
   Add dm_tree_retry_remove to use retry logic for device removal in a dm_tree.
   Add dm_device_has_mounted_fs fn to check mounted filesystem on a device.
--- LVM2/man/dmsetup.8.in	2011/09/22 17:12:28	1.43
+++ LVM2/man/dmsetup.8.in	2011/09/23 09:51:37	1.44
@@ -20,7 +20,7 @@
 .I [--nolockfs] [--noflush] device_name
 .br
 .B dmsetup resume
-.I device_name
+.I device_name [{ --addnodeonresume | --addnodeoncreate }]
 .br
 .B dmsetup load
 .I device_name [--table <table> | table_file]
@@ -313,7 +313,7 @@
 Sets the uuid of a device that was created without a uuid.
 After a uuid has been set it cannot be changed.
 .IP \fBresume
-.I device_name
+.I device_name [{ --addnodeonresume | --addnodeoncreate }]
 .br
 Un-suspends a device.  
 If an inactive table has been loaded, it becomes live.


