From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 May 2009 15:25:23 -0000
Subject: LVM2/lib/report columns.h
Message-ID: <20090506152523.30195.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-06 15:25:23

Modified files:
	lib/report     : columns.h 

Log message:
	Update columns.h comment.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/lib/report/columns.h	2009/04/25 01:18:00	1.34
+++ LVM2/lib/report/columns.h	2009/05/06 15:25:23	1.35
@@ -35,7 +35,10 @@
  * it is pointer that may be used to derive the data value (for example,
  * seg_count - see _lvsegcount_disp()).  In the FIELD macro definition,
  * this is used in an offset calculation to derive the offset to the
- * data value from the containing struct base address.
+ * data value from the containing struct base address.  Note that in some
+ * cases, the argument is the first member of the struct, in which case the
+ * data value pointer points to the start of the struct itself (for example,
+ * 'lvid' field of struct 'lv').
  * 6. Minimum display width.  This is the minimum width used to display
  * the field value.
  * 7. Display function identifier.  Used to derive the full name of the


