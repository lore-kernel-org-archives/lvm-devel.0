From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2009 16:27:59 -0000
Subject: LVM2/lib/report columns.h
Message-ID: <20090423162759.5875.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-04-23 16:27:58

Modified files:
	lib/report     : columns.h 

Log message:
	Update columns.h comment to describe macro args.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/lib/report/columns.h	2009/04/21 12:57:32	1.32
+++ LVM2/lib/report/columns.h	2009/04/23 16:27:58	1.33
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -13,9 +13,44 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-/* Report type, Containing struct, Field type, Report heading,
- * Data field with struct to pass to display function, Minimum display width,
- * Display Fn, Unique format identifier */
+/*
+ * This file defines the fields (columns) for the reporting commands
+ * (pvs/vgs/lvs).
+ */
+/*
+ * The 'FIELD' macro arguments are defined as follows:
+ * 1. report_type.  An enum value that selects a specific
+ * struct dm_report_object_type in the _report_types array.  The value is
+ * used to select the containing base object address (see *obj_get*
+ * functions) for any data values of any field in the report.
+ * 2. Containing struct.  The structure that either contains the field data
+ * as a member or should be used to obtain the field data.  The containing
+ * struct should match the base object of the report_type.
+ * 3. Field type.  This must be either 'STR' or 'NUM'.
+ * 4. Report heading.  This is the field heading that is displayed by the
+ * reporting commands.
+ * 5. Data value pointer.  This argument is is always a member of the
+ * containing struct.  In some cases, the member points to the data value
+ * of the field (for example, lv_uuid - see _uuid_disp()).  In other cases
+ * it is pointer that may be used to derive the data value (for example,
+ * seg_count - see _lvsegcount_disp()).  In the FIELD macro definition,
+ * this is used in an offset calculation to derive the offset to the
+ * data value from the containing struct base address.
+ * 6. Minimum display width.  This is the minimum width used to display
+ * the field value.
+ * 7. Display function identifier.  Used to derive the full name of the
+ * function that displays this field.  Derivation is done by appending '_'
+ * then prepending this argument to '_disp'.  For example, if this argument
+ * is 'uuid', the display function is _uuid_disp().  Adding a new field may
+ * require defining a new display function (for example _myfieldname_disp()),
+ * or re-use of an existing one (for example, _uint32_disp()).
+ * 8. Unique format identifier / field id.  This name must be unique and is
+ * used to select fields via '-o' in the reporting commands (pvs/vgs/lvs).
+ * The string used to specify the field - the 'id' member of
+ * struct dm_report_field_type.
+ * 9. Description of field.  This is a brief (ideally <= 52 chars) description
+ * of the field used in the reporting commands.
+ */
 
 /* *INDENT-OFF* */
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier")


