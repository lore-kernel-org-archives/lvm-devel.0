From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Feb 2012 09:53:13 -0000
Subject: LVM2/udev Makefile.in 69-dm-lvm-metad.rules
Message-ID: <20120224095313.20658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-24 09:53:12

Modified files:
	udev           : Makefile.in 
Added files:
	udev           : 69-dm-lvm-metad.rules 

Log message:
	Add skeleton for lvmetad udev rules - 69-dm-lvm-metad.rules.
	
	Why using the order 69:
	
	- Storage processing in general happens in 60-persistent-storage.rules,
	including the blkid call that adds some usable information we can use
	for filtering and speedup (these rules are part of upstream udev and
	the order is preserved on most distros)
	
	- There's still some other storage-related processing done after
	60-persistent-storage.rules in general. These might add some detailed
	storage-related information we might use to filter devices effectively
	(e.g. MD udev rules, ...).
	
	- We need lvmetad rules to be processed before any consumers can use the
	output - so the metadata cache is ready soon enough (e.g. udisks rules).
	
	- There's no official (upstream udev) document about assigning the order,
	so this number is chosen in best belief it will suit all scenarios.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/69-dm-lvm-metad.rules.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

/cvs/lvm2/LVM2/udev/69-dm-lvm-metad.rules,v  -->  standard output
revision 1.1
--- LVM2/udev/69-dm-lvm-metad.rules
+++ -	2012-02-24 09:53:13.057614000 +0000
@@ -0,0 +1,25 @@
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+
+# Udev rules for LVM.
+#
+# Scan all block devices having a PV label for LVM metadata.
+# Store this information in LVMetaD (the LVM metadata daemon) and maintain LVM
+# metadata state for improved performance by avoiding further scans while
+# running subsequent LVM commands or while using lvm2app library.
+# Also, notify LVMetaD about any relevant block device removal.
+#
+# This rule is essential for having the information in LVMetaD up-to-date.
+# It also requires blkid to be called on block devices before so only devices
+# used as LVM PVs are processed (ID_FS_TYPE="LVM2_member" or "LVM1_member").
+
+SUBSYSTEM!="block", GOTO="lvm_end"
+
+# Device-mapper devices are processed only on change event or on supported synthesized event.
+KERNEL=="dm-[0-9]*", ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="lvm_end"
+
+# Only process devices already marked as a PV - this requires blkid to be called before.
+ENV{ID_FS_TYPE}=="LVM2_member|LVM1_member", RUN+="$env{DM_SBIN_PATH}/pvscan --lvmetad $major:$minor"
+
+LABEL="lvm_end"
--- LVM2/udev/Makefile.in	2012/02/23 10:01:12	1.10
+++ LVM2/udev/Makefile.in	2012/02/24 09:53:12	1.11
@@ -19,6 +19,10 @@
 LVM_RULES=11-dm-lvm.rules
 DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk '{print $$3}')
 
+ifeq ("@BUILD_LVMETAD@", "yes")
+LVM_RULES+=69-dm-lvm-metad.rules
+endif
+
 ifeq ("@UDEV_HAS_BUILTIN_BLKID@", "yes")
 	BLKID_RULE=IMPORT{builtin}=\"blkid\"
 else


