From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Mar 2012 10:43:53 -0000
Subject: LVM2 tools/lvmcmdline.c tools/tools.h test/she ...
Message-ID: <20120316104353.14779.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-16 10:43:52

Modified files:
	tools          : lvmcmdline.c tools.h 
Added files:
	test/shell     : activate-minor.sh 

Log message:
	Fix a regression in handling --major/--minor arguments to lvcreate & lvchange,
	by allowing arg_int_value to be used with groupable options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-minor.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/tools/lvmcmdline.c	2012/03/12 14:15:04	1.154
+++ LVM2/tools/lvmcmdline.c	2012/03/16 10:43:52	1.155
@@ -94,9 +94,24 @@
 	return grouped_arg_count(av, a) ? av[a].i_value : def;
 }
 
+int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
+{
+	struct arg_value_group_list *current_group;
+	struct arg_values *av;
+
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups)  {
+		av = current_group->arg_values;
+		if (grouped_arg_count(av, a))
+			return grouped_arg_int_value(av, a, def);
+	}
+
+	return def;
+}
+
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
 {
-	return arg_count(cmd, a) ? cmd->arg_values[a].i_value : def;
+	return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ?
+		first_grouped_arg_int_value(cmd, a, def) : (arg_count(cmd, a) ? cmd->arg_values[a].i_value : def);
 }
 
 uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
--- LVM2/tools/tools.h	2012/03/06 02:30:50	1.80
+++ LVM2/tools/tools.h	2012/03/16 10:43:52	1.81
@@ -162,6 +162,7 @@
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
+int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 
 uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def);
 int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def);
 uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def);
/cvs/lvm2/LVM2/test/shell/activate-minor.sh,v  -->  standard output
revision 1.1
--- LVM2/test/shell/activate-minor.sh
+++ -	2012-03-16 10:43:53.197583000 +0000
@@ -0,0 +1,19 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 2
+lvcreate -a n --zero n -l 1 -n foo $vg
+lvchange $vg/foo -My --major=255 --minor=123
+lvchange $vg/foo -a y
+dmsetup info $vg-foo | tee info
+grep "254, 123" info


