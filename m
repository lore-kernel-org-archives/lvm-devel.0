From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:35:58 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20120312143558.2334.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:35:58

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Simplify error path code for filter initialization
	
	Use 'int' counter.
	Use 'bad' with goto_bad macro.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.154&r2=1.155

--- LVM2/lib/commands/toolcontext.c	2012/03/12 14:15:04	1.154
+++ LVM2/lib/commands/toolcontext.c	2012/03/12 14:35:57	1.155
@@ -730,7 +730,7 @@
 
 static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 {
-	unsigned nr_filt = 0;
+	int nr_filt = 0;
 	const struct dm_config_node *cn;
 	struct dev_filter *filters[MAX_FILTERS];
 	struct dev_filter *composite;
@@ -761,14 +761,14 @@
 
 	else if (!(filters[nr_filt++] = regex_filter_create(cn->v))) {
 		log_error("Failed to create regex device filter");
-		goto err;
+		goto bad;
 	}
 
 	/* device type filter. Required. */
 	cn = find_config_tree_node(cmd, "devices/types");
 	if (!(filters[nr_filt++] = lvm_type_filter_create(cmd->proc_dir, cn))) {
 		log_error("Failed to create lvm type filter");
-		goto err;
+		goto bad;
 	}
 
 	/* md component filter. Optional, non-critical. */
@@ -790,17 +790,14 @@
 	if (nr_filt == 1)
 		return filters[0];
 
-	if (!(composite = composite_filter_create(nr_filt, filters))) {
-		stack;
-		nr_filt++; /* compensate skip NULL */
-		goto err;
-	}
+	if (!(composite = composite_filter_create(nr_filt, filters)))
+		goto_bad;
 
 	return composite;
-err:
-	nr_filt--; /* skip NULL */
-	while (nr_filt-- > 0)
+bad:
+	while (--nr_filt >= 0)
 		 filters[nr_filt]->destroy(filters[nr_filt]);
+
 	return NULL;
 }
 


