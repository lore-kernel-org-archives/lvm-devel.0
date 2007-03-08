From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Mar 2007 19:22:53 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20070308192253.25516.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-08 19:22:52

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Fix two more segfaults if an empty config file section encountered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.577&r2=1.578
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2007/02/28 18:27:11	1.577
+++ LVM2/WHATS_NEW	2007/03/08 19:22:52	1.578
@@ -1,5 +1,6 @@
 Version 2.02.23 - 
 ====================================
+  Fix two more segfaults if an empty config file section encountered.
   Move .cache file into a new /etc/lvm/cache directory by default.
   Add devices/cache_dir & devices/cache_file_prefix, deprecating devices/cache.
   Create directory in fcntl_lock_file() if required.
--- LVM2/lib/config/config.c	2007/01/25 14:37:47	1.53
+++ LVM2/lib/config/config.c	2007/03/08 19:22:52	1.54
@@ -878,7 +878,7 @@
 {
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
 
-	if (n && n->v->type == CFG_INT) {
+	if (n && n->v && n->v->type == CFG_INT) {
 		log_very_verbose("Setting %s to %d", path, n->v->v.i);
 		return n->v->v.i;
 	}
@@ -899,7 +899,7 @@
 {
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
 
-	if (n && n->v->type == CFG_FLOAT) {
+	if (n && n->v && n->v->type == CFG_FLOAT) {
 		log_very_verbose("Setting %s to %f", path, n->v->v.r);
 		return n->v->v.r;
 	}


