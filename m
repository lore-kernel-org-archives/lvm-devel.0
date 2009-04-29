From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:28 -0400
Subject: [PATCH 2/8] Add lvm_object_prop.pl to generate liblvm object property function prototype
In-Reply-To: <1241034934-25639-2-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
	<1241034934-25639-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1241034934-25639-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The term 'attribute' is used in some of the reporting fields (e.g. vg_attr),
so we avoid it here and instead use the term 'properties' or 'prop'.

NOTE: The intent of the perl code, lvm_object_prop.pl, is to help maintain
liblvm object property consistency with the reporting commands pvs, vgs, lvs
As new fields get added to columns.h, we should re-run this script on the ne
FIELD line(s), take the generated code, edit as appropriate, and place into
appropriate liblvm code file.

This patch adds the perl file, lvm_object_prop.pl.  A later patch will
add the files this code generates, namely the liblvm object property
function header and C file, lvm_object_prop.[ch].

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/lvm_object_prop.pl |  221 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 221 insertions(+), 0 deletions(-)
 create mode 100644 liblvm/lvm_object_prop.pl

diff --git a/liblvm/lvm_object_prop.pl b/liblvm/lvm_object_prop.pl
new file mode 100644
index 0000000..08c492d
--- /dev/null
+++ b/liblvm/lvm_object_prop.pl
@@ -0,0 +1,221 @@
+#!/usr/bin/perl
+#
+# Take the colunms.h file as input and produce a header and
+# default code for liblvm object property accessor and mutator functions.
+# To run: perl lvm_object_prop.pl < ../lib/report/columns.h
+#
+# For maintenance purposes, when adding a new line to columns.h,
+# we can pipe the diff to this program to generate the new prototypes
+# and C code, then cut/paste into the proper liblvm files.
+#
+
+sub write_code_header;
+sub write_code_body;
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
+    # Some field names/ids contain the struct name, while others don't.
+    # For consistency, if the field name contains the struct name, remove
+    # it (we always put the object name in the function name.
+    #
+    if ($id =~ /^$strct/) {
+	$id = substr($id,length($strct)+1,length($id));
+    }
+    if ($sorttype =~ m/STR/) {
+	$attr_type = "const char *";
+    } else {
+	$attr_type = "const uint64_t ";
+    }
+    # Write 'get' prototype to header and code to C file.
+    write_include_body(INCLUDE_FILE, $object, $id, $desc, $attr_type);
+    write_code_body(CODE_FILE, $object, $sorttype, $id, $desc, $attr_type);
+
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
+    print $file <<ENDHEADER;
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
+ENDHEADER
+}
+
+sub write_include_body
+{
+    my($file, $object, $id, $desc, $attr_type) = @_;
+    #
+    # Use the description and field name in the comment
+    #
+    print $file "/**\n";
+    print $file " * "."lvm_"."$object"."_{get|set}_$id\n";
+    print $file " * $id - $desc\n";
+    print $file " */\n";
+    # Write out 'get' method prototype
+    $fun_name = "lvm_"."$object"."_get_$id";
+    $fun_args = "($object"."_t *$object)";
+    print $file "$attr_type"."$fun_name"."$fun_args".";\n";
+    # Write out 'set' method prototype
+    $fun_name = "lvm_"."$object"."_set_$id";
+    $fun_args = "($object"."_t *$object, $attr_type"."value)";
+    print $file "int "."$fun_name"."$fun_args".";\n\n";
+}
+
+sub write_include_footer
+{
+    my($file) = @_;
+    print $file <<ENDFOOTER;
+#endif
+ENDFOOTER
+}
+
+sub write_code_header
+{
+    my($file) = @_;
+    print $file <<ENDCODE1;
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
+
+ENDCODE1
+}
+
+sub write_code_body
+{
+    my($file, $object, $sorttype, $id, $desc, $attr_type) = @_;
+    print $file "/**\n";
+    print $file " * "."lvm_"."$object"."_{get|set}_$id\n";
+    print $file " * $id - $desc\n";
+    print $file " */\n";
+    # Write out 'get' method
+    $fun_name = "lvm_"."$object"."_get_$id";
+    $fun_args = "($object"."_t *$object)";
+    print $file "$attr_type"."$fun_name"."$fun_args"."\n";
+    if ($sorttype =~ m/STR/) {
+        print $file <<ENDCODE4;
+{
+    /* FIXME: implement function body */
+    return ($attr_type)0;
+}
+ENDCODE4
+	} else {
+    print $file <<ENDCODE5;
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+
+ENDCODE5
+    }
+    # Write out 'set' method
+    $fun_name = "lvm_"."$object"."_set_$id";
+    $fun_args = "($object"."_t *$object, $attr_type"."value)";
+    print $file "int "."$fun_name"."$fun_args"."\n";
+    print $file <<ENDCODE2;
+{
+    /* FIXME: implement function body */
+    return -1;
+}
+ENDCODE2
+}
+
+
+sub write_code_footer
+{
+# nothing to do
+}
-- 
1.6.0.6


