From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Jan 2007 16:22:59 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20070117162259.9017.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-17 16:22:59

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Fix a segfault if an empty config file section encountered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.543&r2=1.544
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2007/01/16 18:06:10	1.543
+++ LVM2/WHATS_NEW	2007/01/17 16:22:59	1.544
@@ -1,5 +1,6 @@
 Version 2.02.19 - 
 ===================================
+  Fix a segfault if an empty config file section encountered.
   Move basic reporting functions into libdevmapper.
   Fix partition table processing after sparc changes (2.02.16).
   Fix cmdline PE range processing segfault (2.02.13).
--- LVM2/lib/config/config.c	2007/01/09 23:22:31	1.51
+++ LVM2/lib/config/config.c	2007/01/17 16:22:59	1.52
@@ -853,7 +853,7 @@
 	const struct config_node *n = _find_first_config_node(cn1, cn2, path);
 
 	/* Empty strings are ignored */
-	if ((n && n->v->type == CFG_STRING) && (*n->v->v.str)) {
+	if ((n && n->v && n->v->type == CFG_STRING) && (*n->v->v.str)) {
 		log_very_verbose("Setting %s to %s", path, n->v->v.str);
 		return n->v->v.str;
 	}


