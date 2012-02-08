From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 10:49:37 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20120208104937.19860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 10:49:37

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 

Log message:
	Fix resource leaks for failing allocation
	
	In case, something would fail during format initialization,
	return allocated memory.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2259&r2=1.2260
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187

--- LVM2/WHATS_NEW	2012/02/08 10:46:24	1.2259
+++ LVM2/WHATS_NEW	2012/02/08 10:49:36	1.2260
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Fix resource leaks for failing allocation of formats (lvm1/2,pool).
   Release allocated resources in error path for composite_filter_create().
   Do not use lstat() results when failed in _rm_link().
   Remove a "waiting for another thread" log message from dmeventd plugins.
--- LVM2/lib/format1/format1.c	2011/06/01 19:29:32	1.139
+++ LVM2/lib/format1/format1.c	2012/02/08 10:49:36	1.140
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -587,11 +587,14 @@
 
 	if (!(fmt->labeller = lvm1_labeller_create(fmt))) {
 		log_error("Couldn't create lvm1 label handler.");
+		dm_free(fmt);
 		return NULL;
 	}
 
 	if (!(label_register_handler(FMT_LVM1_NAME, fmt->labeller))) {
 		log_error("Couldn't register lvm1 label handler.");
+		fmt->labeller->ops->destroy(fmt->labeller);
+		dm_free(fmt);
 		return NULL;
 	}
 
--- LVM2/lib/format_pool/format_pool.c	2011/08/10 20:25:30	1.45
+++ LVM2/lib/format_pool/format_pool.c	2012/02/08 10:49:36	1.46
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1997-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -298,11 +298,14 @@
 
 	if (!(fmt->labeller = pool_labeller_create(fmt))) {
 		log_error("Couldn't create pool label handler.");
+		dm_free(fmt);
 		return NULL;
 	}
 
 	if (!(label_register_handler(FMT_POOL_NAME, fmt->labeller))) {
 		log_error("Couldn't register pool label handler.");
+		fmt->labeller->ops->destroy(fmt->labeller);
+		dm_free(fmt);
 		return NULL;
 	}
 
--- LVM2/lib/format_text/format-text.c	2011/11/18 19:31:10	1.186
+++ LVM2/lib/format_text/format-text.c	2012/02/08 10:49:36	1.187
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2362,14 +2362,13 @@
 
 	if (!(fmt->labeller = text_labeller_create(fmt))) {
 		log_error("Couldn't create text label handler.");
-		dm_free(fmt);
-		return NULL;
+		goto err;
 	}
 
 	if (!(label_register_handler(FMT_TEXT_NAME, fmt->labeller))) {
 		log_error("Couldn't register text label handler.");
-		dm_free(fmt);
-		return NULL;
+		fmt->labeller->ops->destroy(fmt->labeller);
+		goto err;
 	}
 
 	if ((cn = find_config_tree_node(cmd, "metadata/dirs"))) {
@@ -2402,8 +2401,7 @@
 	return fmt;
 
       err:
-	_free_dirs(&mda_lists->dirs);
+	_text_destroy(fmt);
 
-	dm_free(fmt);
 	return NULL;
 }


