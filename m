From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Apr 2010 12:37:07 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20100430123707.23496.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-30 12:37:05

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Release pools for regex if there is error during processing
	(fixes error messages about unreleased pools).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1543&r2=1.1544
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2010/04/30 12:31:32	1.1543
+++ LVM2/WHATS_NEW	2010/04/30 12:37:04	1.1544
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Fix memory leak for invalid regex pattern input.
   Display invalid regex pattern for filter configuration in case of error.
   Remove no-longer-used arg_ptr_value.
   Fix -M and --type to use strings not pointers that change on config refresh.
--- LVM2/lib/commands/toolcontext.c	2010/04/29 01:38:14	1.94
+++ LVM2/lib/commands/toolcontext.c	2010/04/30 12:37:05	1.95
@@ -639,14 +639,14 @@
 
 	else if (!(filters[nr_filt++] = regex_filter_create(cn->v))) {
 		log_error("Failed to create regex device filter");
-		return NULL;
+		goto err;
 	}
 
 	/* device type filter. Required. */
 	cn = find_config_tree_node(cmd, "devices/types");
 	if (!(filters[nr_filt++] = lvm_type_filter_create(cmd->proc_dir, cn))) {
 		log_error("Failed to create lvm type filter");
-		return NULL;
+		goto err;
 	}
 
 	/* md component filter. Optional, non-critical. */
@@ -660,6 +660,11 @@
 	/* Only build a composite filter if we really need it. */
 	return (nr_filt == 1) ?
 	    filters[0] : composite_filter_create(nr_filt, filters);
+err:
+	nr_filt--; /* skip NULL */
+	while (nr_filt-- > 0)
+		 filters[nr_filt]->destroy(filters[nr_filt]);
+	return NULL;
 }
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)


