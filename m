From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 20:35:55 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100820203555.1746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 20:35:55

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1717&r2=1.1718

--- LVM2/WHATS_NEW	2010/08/19 23:26:31	1.1717
+++ LVM2/WHATS_NEW	2010/08/20 20:35:55	1.1718
@@ -1,5 +1,12 @@
 Version 2.02.74 - 
 ==================================
+  Add implmentation for simple numeric 'get' property functions.
+  Define GET_NUM_PROPERTY_FN macro to simplify numeric property 'get' function
+  Add properties.[ch] to lib/report, defined based on columns.h.
+  Add macro definitions to report infrastructure for character array length.
+  Remove explicit double quotes from columns.h 'id' entries.
+  Add 'flags' field to columns.h and define FIELD_MODIFIABLE.
+  Add vg_mda_size and vg_mda_free functions.
   Simplify MD/swap signature detection in pvcreate and allow aborting.
   Remove assumption that --yes must be used only in --force mode.
   Fix file descriptor leak in swap signature detection error path.


