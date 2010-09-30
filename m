From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:26:49 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100930142649.29280.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:26:49

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for commits related to generic property functions

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1742&r2=1.1743

--- LVM2/WHATS_NEW	2010/09/30 14:12:14	1.1742
+++ LVM2/WHATS_NEW	2010/09/30 14:26:48	1.1743
@@ -1,5 +1,13 @@
 Version 2.02.75 - 
 =====================================
+  Add pv_get_property and create generic internal _get_property function.
+  Add 'get' functions for pv and vg properties/fields.
+  Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
+  Add tags_format_and_copy() common function and call from _tags_disp.
+  Add id_format_and_copy() common function and call from _uuid_disp.
+  Simplify logic to create '{pv|vg|lv}_attr' strings.
+  Refactor report.c '*_disp' functions to call supporting functions.
+  Refactor lib/metadata/metadata.[ch] into {pv|vg|lv}.[ch].
   Fix memory leak of vg_read while using live copies of metadata in directories.
   Fix memory leak of config_tree in reinitialization code path.
   Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.


