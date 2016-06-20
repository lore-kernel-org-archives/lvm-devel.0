From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:54 +0000 (UTC)
Subject: master - report: recognize list of keys to sort report by (-O|--sort) for each subreport; make -O|--sort groupable
Message-ID: <20160620094054.B614360FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e081203f3e2ee5e3270c7f5f2753ed446d8b72cb
Commit:        e081203f3e2ee5e3270c7f5f2753ed446d8b72cb
Parent:        bd26684d5d9f44f7677f6e30a461542d4280a1b9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 26 15:12:38 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

report: recognize list of keys to sort report by (-O|--sort) for each subreport; make -O|--sort groupable

---
 WHATS_NEW        |    1 +
 tools/args.h     |    2 +-
 tools/reporter.c |   20 ++++++++++++++++++--
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8afc577..fb5d3e7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Make -O|--sort option groupable that allows this option to be repeated.
   Add --configreport option to select report for which next options are applied.
   Add support for priorities on grouping command arguments.
   Add report/{pvs,vgs,lvs,pvsegs,segs}_{cols,sort}_full to lvm.conf.
diff --git a/tools/args.h b/tools/args.h
index c0e0864..985f5d1 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -192,7 +192,7 @@ arg(nofsck_ARG, 'n', "nofsck", NULL, 0, 0)
 arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0, 0)
 arg(oldpath_ARG, 'n', "oldpath", NULL, 0, 0)
 arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE, 0)
-arg(sort_ARG, 'O', "sort", string_arg, 0, 0)
+arg(sort_ARG, 'O', "sort", string_arg, ARG_GROUPABLE, 0)
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0, 0)
 arg(permission_ARG, 'p', "permission", permission_arg, 0, 0)
 arg(partial_ARG, 'P', "partial", NULL, 0, 0)
diff --git a/tools/reporter.c b/tools/reporter.c
index c081e1c..8165288 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -892,10 +892,26 @@ static int _get_report_keys(struct cmd_context *cmd,
 			    struct report_args *args,
 			    struct single_report_args *single_args)
 {
-	int r = ECMD_PROCESSED;
+	struct arg_value_group_list *current_group;
+	const char *report_name = NULL;
+	report_idx_t idx = REPORT_IDX_SINGLE;
+	int r = ECMD_FAILED;
 
-	single_args->keys = arg_str_value(cmd, sort_ARG, single_args->keys);
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, sort_ARG))
+			continue;
 
+		if (grouped_arg_is_set(current_group->arg_values, configreport_ARG)) {
+			report_name = grouped_arg_str_value(current_group->arg_values, configreport_ARG, NULL);
+			if ((idx = _get_report_idx_from_name(single_args->report_type, report_name)) == REPORT_IDX_NULL)
+				goto_out;
+		}
+
+		args->single_args[idx].keys = grouped_arg_str_value(current_group->arg_values, sort_ARG, NULL);
+	}
+
+	r = ECMD_PROCESSED;
+out:
 	return r;
 }
 


