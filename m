From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Nov 2011 11:54:17 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/flags.c
Message-ID: <20111115115417.9067.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-11-15 11:54:17

Modified files:
	.              : WHATS_NEW 
	lib/format_text: flags.c 

Log message:
	Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
	
	When a PV label write is deferred to a vg_write call (as introduced by a patch
	in 2.02.86), the PV is flagged with the internal UNLABELLED_PV flag. However,
	when calling vg_archive before vg_write, we still have the PV labelled with the
	UNLABELLED_PV flag which was not recognised as a proper flag while exporting
	VG metadata:
	
	# vgcreate vg /dev/sda
	No physical volume label read from /dev/sda
	Metadata inconsistency: Not all flags successfully exported.
	Metadata inconsistency: Not all flags successfully exported.
	Writing physical volume data to disk "/dev/sda"
	Physical volume "/dev/sda" successfully created
	Volume group "vg" successfully created

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2183&r2=1.2184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2011/11/14 21:30:35	1.2183
+++ LVM2/WHATS_NEW	2011/11/15 11:54:15	1.2184
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86).
   Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
   Move gentoo MAKEDEV to /sbin in lvm2create_initrd.
   Add filter to avoid scan of device if it is part of active multipath.
--- LVM2/lib/format_text/flags.c	2011/09/08 16:41:18	1.48
+++ LVM2/lib/format_text/flags.c	2011/11/15 11:54:16	1.49
@@ -45,6 +45,7 @@
 	{ALLOCATABLE_PV, "ALLOCATABLE", STATUS_FLAG},
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{MISSING_PV, "MISSING", COMPATIBLE_FLAG},
+	{UNLABELLED_PV, NULL, 0},
 	{0, NULL, 0}
 };
 


