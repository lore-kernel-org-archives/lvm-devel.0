From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Apr 2012 12:49:12 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20120411124912.8805.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-04-11 12:49:10

Modified files:
	tools          : lvmcmdline.c 

Log message:
	spacing

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/tools/lvmcmdline.c	2012/03/16 10:43:52	1.155
+++ LVM2/tools/lvmcmdline.c	2012/04/11 12:49:10	1.156
@@ -99,7 +99,7 @@
 	struct arg_value_group_list *current_group;
 	struct arg_values *av;
 
-	dm_list_iterate_items(current_group, &cmd->arg_value_groups)  {
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		av = current_group->arg_values;
 		if (grouped_arg_count(av, a))
 			return grouped_arg_int_value(av, a, def);


