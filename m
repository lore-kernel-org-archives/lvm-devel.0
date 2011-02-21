From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:40:47 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110221124047.31467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:40:46

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1923&r2=1.1924

--- LVM2/WHATS_NEW	2011/02/18 23:09:55	1.1923
+++ LVM2/WHATS_NEW	2011/02/21 12:40:46	1.1924
@@ -1,5 +1,14 @@
 Version 2.02.85 - 
 ===================================
+  Fix metadata balance code to work with recent changes in metadata handling.
+  Add old_uuid field to physical_volume and fix pvchange -u for recent changes.
+  Fix vgconvert to work with recent changes in metadata handling.
+  Allow pvresize on a PV with two metadata areas.
+  Change pvcreate to use new metadata handling interface.
+  Restructure existing pv_setup and pv_write fn, add pv_initialise fn.
+  Add internal interface to support adding and removing metadata areas.
+  Allow internal indexing of metadata areas (PV id + mda order).
+  Generalise internal format_instance infrastrusture for PV and VG use.
   Handle decimal digits with --units instead of ignoring them silently.
   Fix remaining warnings and compile with -Wpointer-arith.
   Fix gcc warnings for unused variables.


