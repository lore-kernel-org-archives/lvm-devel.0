From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jun 2010 17:03:16 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdevma ...
Message-ID: <20100623170316.14717.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-23 17:03:15

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	libdm          : libdevmapper.h 

Log message:
	In some C++ standards, typeof is not reserved.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1630&r2=1.1631
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.380&r2=1.381
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/WHATS_NEW	2010/06/23 16:24:13	1.1630
+++ LVM2/WHATS_NEW	2010/06/23 17:03:14	1.1631
@@ -1,12 +1,10 @@
 Version 2.02.68 -
 ===============================
   Fix clvmd initscript status to print only active clustered LVs.
-  Fix typo "INTERNAL ERROR" -> "INTERNAL_ERROR" in libdm-iface.c.
   Add lv_path to reports to offer full /dev pathname.
   Fix typo in warning message about missing device with allocated data areas.
-  Add device name and offset to output of error messages in raw_read_mda_header().
-  Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
-  Honor log argument when down-converting stacked mirror.
+  Add device name and offset to raw_read_mda_header error messages.
+  Honour log argument when down-converting stacked mirror.
   Sleep to workaround clvmd -S race: socket closed early and server drops cmd.
   Use early udev synchronisation and update of dev nodes for clustered mirrors.
   Remove incorrect inclusion of kdev_t.h from cmirrord/functions.h.
--- LVM2/WHATS_NEW_DM	2010/06/23 17:00:32	1.380
+++ LVM2/WHATS_NEW_DM	2010/06/23 17:03:15	1.381
@@ -1,7 +1,9 @@
 Version 1.02.50 - 
 ===============================
+  Fix INTERNAL_ERROR typo in ioctl iface unknown task message.
   Fix udev rules to handle spurious events properly.
-  Allow use of devmapper header file in C++ mode.
+  Use C99 [] not [0] in dm_ulog_request struct to avoid abort when fortified.
+  Allow use of devmapper header file in C++ mode (extern "C" and __typeof__).
 
 Version 1.02.49 - 4th June 2010
 ===============================
--- LVM2/libdm/libdevmapper.h	2010/06/16 13:01:25	1.116
+++ LVM2/libdm/libdevmapper.h	2010/06/23 17:03:15	1.117
@@ -29,6 +29,10 @@
 #include <stdlib.h>
 #include <stdio.h>
 
+#ifndef __GNUC__
+# define __typeof__ typeof
+#endif
+
 #ifdef __cplusplus
 extern "C" {
 #endif
@@ -855,9 +859,9 @@
  * The 'struct dm_list' variable within the containing structure is 'field'.
  */
 #define dm_list_iterate_items_gen(v, head, field) \
-	for (v = dm_list_struct_base((head)->n, typeof(*v), field); \
+	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field); \
 	     &v->field != (head); \
-	     v = dm_list_struct_base(v->field.n, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.n, __typeof__(*v), field))
 
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
@@ -873,10 +877,10 @@
  * t must be defined as a temporary variable of the same type as v.
  */
 #define dm_list_iterate_items_gen_safe(v, t, head, field) \
-	for (v = dm_list_struct_base((head)->n, typeof(*v), field), \
-	     t = dm_list_struct_base(v->field.n, typeof(*v), field); \
+	for (v = dm_list_struct_base((head)->n, __typeof__(*v), field), \
+	     t = dm_list_struct_base(v->field.n, __typeof__(*v), field); \
 	     &v->field != (head); \
-	     v = t, t = dm_list_struct_base(v->field.n, typeof(*v), field))
+	     v = t, t = dm_list_struct_base(v->field.n, __typeof__(*v), field))
 /*
  * Walk a list, setting 'v' in turn to the containing structure of each item.
  * The containing structure should be the same type as 'v'.
@@ -893,9 +897,9 @@
  * The 'struct dm_list' variable within the containing structure is 'field'.
  */
 #define dm_list_iterate_back_items_gen(v, head, field) \
-	for (v = dm_list_struct_base((head)->p, typeof(*v), field); \
+	for (v = dm_list_struct_base((head)->p, __typeof__(*v), field); \
 	     &v->field != (head); \
-	     v = dm_list_struct_base(v->field.p, typeof(*v), field))
+	     v = dm_list_struct_base(v->field.p, __typeof__(*v), field))
 
 /*
  * Walk a list backwards, setting 'v' in turn to the containing structure 


