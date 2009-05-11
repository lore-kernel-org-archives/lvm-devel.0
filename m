From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:15 -0400
Subject: [PATCH 02/30] Add lvm_object_prop.pl to generate liblvm object property functions.
In-Reply-To: <1242046903-15133-2-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The intent of this perl code, lvm_object_prop.pl, is to help maintain
liblvm object property consistency with the reporting commands pvs, vgs, lvs.
As new fields get added to columns.h, we should re-run this script on the new
FIELD line(s), take the generated code, edit as appropriate, and place into
appropriate liblvm code file.

This patch adds the perl file, lvm_object_prop.pl.  A later patch will
add the files this code generates, namely the liblvm object property
function header and C file, lvm_object_prop.[ch].

NOTE: The term 'attribute' is used in some of the reporting fields (for
example, vg_attr), so we avoid it here and instead use the term 'properties'
or 'prop'.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.pl |  232 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 232 insertions(+), 0 deletions(-)
 create mode 100644 lib/report/lvm_object_prop.pl

diff --git a/lib/report/lvm_object_prop.pl b/lib/report/lvm_object_prop.pl
new file mode 100644
index 0000000..824d33a
--- /dev/null
+++ b/lib/report/lvm_object_prop.pl
@@ -0,0 +1,232 @@
+#!/usr/bin/perl
+#
+# Take the colunms.h file as input and produce a header and
+# default code for liblvm object property accessor and mutator functions.
+# To run: perl lvm_object_prop.pl < columns.h
+#
+# For maintenance purposes, when adding a new line to columns.h,
+# we can pipe the diff to this program to generate the new prototypes
+# and C code, then cut/paste into the proper liblvm files.
+#
+
+sub write_code_header;
+sub write_code_body;
+sub write_code_body_get;
+sub write_code_footer;
+sub write_include_header;
+sub write_include_body;
+sub write_include_footer;
+
+#
+# Open the files and write the headers
+#
+$outfile = "lvm_object_prop";
+open(INCLUDE_FILE, ">./$outfile.h") || die "Cannot open $outfile.h!\n";
+write_include_header(INCLUDE_FILE);
+open(CODE_FILE, ">./$outfile.c") || die "Cannot open $outfile.c!\n";
+write_code_header(CODE_FILE);
+
+#
+# Write the include and code body
+#
+while(<>) {
+    # Skip if line does not begin w/"FIELD" - not perfect but does the job
+    if ($_ !~ /^FIELD/) {
+	next;
+    }
+    # Pull out the actual parameters to the FIELD macro
+    m%FIELD\((.*)\)%;
+    $_ = $1;
+
+    #FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier")
+    # NOTE: I tried using Text:CSV but could not make it work.
+    # Parse using brute force regex
+    m%(\S+),\s*(\S+),\s*(\S+),\s*(\".*\"),\s*(\S+),\s*(\S+),\s*(\S+),\s*(\".*\"),\s*(\".*\")%;
+    ($type, $strct, $sorttype, $head, $field, $width, $func, $id, $desc) =
+	    ($1, $2, $3, $4, $5, $6, $7, $8, $9);
+
+    #
+    # Fixup the id / field name / attribute name
+    #
+
+    # Unquote 'id' (field name) and description
+    $id =~ tr/"//d;
+    $desc =~ tr/"//d;
+
+    # Skip redundant fields
+    if ($id =~ /^(stripesize|regionsize|chunksize)$/) {
+        next;
+    }
+
+    # Map report type to liblvm object name
+    # - PVS, VGS, LVS reports, the liblvm object is pv/vg/lv
+    # - PVSEG, the object is pvseg
+    # - SEG, the object is lvseg
+    # - LABEL, the object is pv
+    if ($type =~ /^PVS$/) {
+	$object = "pv";
+    } elsif ($type =~ /^VGS$/) {
+	$object = "vg";
+    } elsif ($type =~ /^LVS$/) {
+	$object = "lv";
+    } elsif ($type =~ /^LABEL$/) {
+	$object = "pv";
+    } elsif ($type =~ /^SEGS$/) {
+	$object = "lvseg";
+    } elsif ($type =~ /^PVSEGS$/) {
+	$object = "pvseg";
+    } else {
+	print "Skipping type: $type, line: $_\n"; #DEBUG
+	next;
+    }
+
+    # lv_kernel_major and lv_kernel_minor are 'STR' but we make them uint64_t here
+    # as this seems more appropriate and easier to manage.
+    if ($id =~ /^(lv_kernel_major|lv_kernel_minor)$/) {
+	$prop_type = "uint64_t ";
+    } elsif ($sorttype =~ m/STR/) {
+	$prop_type = "char *";
+    } else {
+	$prop_type = "uint64_t ";
+    }
+
+    # Some field names/ids contain the struct name, while others don't.
+    # For consistency, if the field name contains the struct name, remove
+    # it (we always put the object name in the function name.
+    #
+    if ($id =~ /^$strct/) {
+	$id = substr($id,length($strct)+1,length($id));
+    }
+
+    # Write 'get' prototype to header and code to C file.
+    write_include_body(INCLUDE_FILE, $object, $id, $desc, $prop_type);
+    write_code_body(CODE_FILE, $object, $id, $desc, $prop_type, $func, $field);
+}
+
+write_include_footer(INCLUDE_FILE);
+write_code_footer(CODE_FILE);
+close(INCLUDE_FILE);
+close(CODE_FILE);
+
+sub write_include_header
+{
+    my($file) = @_;
+    print $file <<END_INCLUDE_HEADER;
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_OBJECT_PROP_H
+#define _LVM_OBJECT_PROP_H
+
+END_INCLUDE_HEADER
+}
+
+sub write_include_body
+{
+    my($file, $object, $id, $desc, $prop_type) = @_;
+    #
+    # Use the description and field name in the comment
+    #
+    print $file "/**\n";
+    print $file " * "."lvm_"."$object"."_{get|set}_$id\n";
+    print $file " * $id - $desc\n";
+    print $file " */\n";
+    # Write out 'get' method prototype
+    $fun_name = "lvm_"."$object"."_get_$id";
+    $fun_args = "(const $object"."_t *$object)";
+    print $file "$prop_type"."$fun_name"."$fun_args".";\n";
+    # Write out 'set' method prototype
+    $fun_name = "lvm_"."$object"."_set_$id";
+    $fun_args = "($object"."_t *$object, const $prop_type"."value)";
+    print $file "int "."$fun_name"."$fun_args".";\n\n";
+}
+
+sub write_include_footer
+{
+    my($file) = @_;
+    print $file <<END_INCLUDE_FOOTER;
+#endif
+END_INCLUDE_FOOTER
+}
+
+sub write_code_header
+{
+    my($file) = @_;
+    print $file <<END_CODE_HEADER;
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+#include "lvm.h"
+#include "lib.h"
+#include "metadata-exported.h"
+
+END_CODE_HEADER
+}
+
+sub write_code_body_get
+{
+    my($file, $object, $func, $field, $fun_name, $prop_type, $id) = @_;
+
+    if ($func =~ /^(int32|uint32|size32|size64)$/) {
+	$code = "\treturn $object->$field;";
+    } else {
+	$code = "\t/* FIXME: implement function body */\n\treturn 0;";
+    }
+    print $file <<END_CODE_GET;
+{
+$code
+}
+END_CODE_GET
+}
+
+sub write_code_body
+{
+    my($file, $object, $id, $desc, $prop_type, $func, $field) = @_;
+    print $file "/**\n";
+    print $file " * "."lvm_"."$object"."_{get|set}_$id\n";
+    print $file " * $id - $desc\n";
+    print $file " */\n";
+    # Write out 'get' method
+    $fun_name = "lvm_"."$object"."_get_$id";
+    $fun_args = "(const $object"."_t *$object)";
+    print $file "$prop_type"."$fun_name"."$fun_args"."\n";
+    write_code_body_get($file, $object, $func, $field, $fun_name, $prop_type, $id);
+
+    # Write out 'set' method; all sets require internal logic so no autogeneration
+    $fun_name = "lvm_"."$object"."_set_$id";
+    $fun_args = "($object"."_t *$object, const $prop_type"."value)";
+    print $file "int "."$fun_name"."$fun_args"."\n";
+    $code = "\t/* FIXME: implement function body */\n\treturn -1;";
+    print $file <<END_CODE_SET;
+{
+$code
+}
+END_CODE_SET
+}
+
+
+sub write_code_footer
+{
+# nothing to do
+}
-- 
1.6.0.6


