From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 Apr 2010 18:17:57 -0000
Subject: LVM2 ./WHATS_NEW tools/commands.h
Message-ID: <20100420181757.1214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-04-20 18:17:56

Modified files:
	.              : WHATS_NEW 
	tools          : commands.h 

Log message:
	Remove -n argument from vgcfgrestore.
	
	This is old lvm1 syntax, because arguments changed
	from PVs to VGs compatibility is broken already.
	
	name_ARG is not used in code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1531&r2=1.1532
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.144&r2=1.145

--- LVM2/WHATS_NEW	2010/04/20 14:07:37	1.1531
+++ LVM2/WHATS_NEW	2010/04/20 18:17:56	1.1532
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Remove obsolete --name parameter from vgcfgrestore.
   Add -S command to clvmd to restart the daemon preserving exclusive locks.
   Increment lvm2app version from 1 to 2.
   Change lvm2app memory alloc/free for pv/vg/lv properties.
--- LVM2/tools/commands.h	2010/04/13 01:54:34	1.144
+++ LVM2/tools/commands.h	2010/04/20 18:17:56	1.145
@@ -688,14 +688,13 @@
    "\t[-f|--file filename] " "\n"
    "\t[-l[l]|--list [--list]]" "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[-n|--name VolumeGroupName] " "\n"
    "\t[-h|--help]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\tVolumeGroupName",
 
-   file_ARG, list_ARG, metadatatype_ARG, name_ARG, test_ARG)
+   file_ARG, list_ARG, metadatatype_ARG, test_ARG)
 
 xx(vgchange,
    "Change volume group attributes",


