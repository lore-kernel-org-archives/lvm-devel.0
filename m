From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 10:46:26 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20120208104626.18535.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 10:46:25

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Release allocated resources in error path
	
	If composite_filter_create() fails, release filters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2258&r2=1.2259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/WHATS_NEW	2012/02/08 10:43:42	1.2258
+++ LVM2/WHATS_NEW	2012/02/08 10:46:24	1.2259
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Release allocated resources in error path for composite_filter_create().
   Do not use lstat() results when failed in _rm_link().
   Remove a "waiting for another thread" log message from dmeventd plugins.
 
--- LVM2/lib/commands/toolcontext.c	2012/02/01 13:42:19	1.148
+++ LVM2/lib/commands/toolcontext.c	2012/02/08 10:46:24	1.149
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -728,6 +728,7 @@
 	unsigned nr_filt = 0;
 	const struct dm_config_node *cn;
 	struct dev_filter *filters[MAX_FILTERS];
+	struct dev_filter *composite;
 
 	memset(filters, 0, sizeof(filters));
 
@@ -781,8 +782,16 @@
 	}
 
 	/* Only build a composite filter if we really need it. */
-	return (nr_filt == 1) ?
-	    filters[0] : composite_filter_create(nr_filt, filters);
+	if (nr_filt == 1)
+		return filters[0];
+
+	if (!(composite = composite_filter_create(nr_filt, filters))) {
+		stack;
+		nr_filt++; /* compensate skip NULL */
+		goto err;
+	}
+
+	return composite;
 err:
 	nr_filt--; /* skip NULL */
 	while (nr_filt-- > 0)


