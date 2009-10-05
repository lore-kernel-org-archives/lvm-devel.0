From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:22:59 -0000
Subject: LVM2/tools commands.h
Message-ID: <20091005202259.29250.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:22:59

Modified files:
	tools          : commands.h 

Log message:
	Update help messages for vgextend / vgcreate to mention PHYSICAL DEVICE OPTIONS.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/tools/commands.h	2009/10/05 20:04:08	1.132
+++ LVM2/tools/commands.h	2009/10/05 20:22:58	1.133
@@ -754,7 +754,8 @@
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
-   "\tVolumeGroupName PhysicalVolume [PhysicalVolume...]\n",
+   "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
+   "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
@@ -820,6 +821,7 @@
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
+   "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    autobackup_ARG, test_ARG,


