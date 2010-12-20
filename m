From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 13:45:40 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-regex.c
Message-ID: <20101220134540.12343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 13:45:40

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-regex.c 

Log message:
	Fix error path if regex engine cannot be created in _build_matcher().
	
	Fix only 'stack' printing with full function error exit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1843&r2=1.1844
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/WHATS_NEW	2010/12/20 13:37:26	1.1843
+++ LVM2/WHATS_NEW	2010/12/20 13:45:39	1.1844
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Fix error path if regex engine cannot be created in _build_matcher().
   Use char* arithmetic in target_version(), _process_all(), _targets().
   Fixing const cast gcc warnings in the code.
   Check read() and close() results in _get_cmdline().
--- LVM2/lib/filters/filter-regex.c	2010/12/20 13:12:56	1.29
+++ LVM2/lib/filters/filter-regex.c	2010/12/20 13:45:40	1.30
@@ -137,7 +137,7 @@
 	 */
 	if (!(rf->engine = dm_regex_create(rf->mem, (const char **) regex,
 					   count)))
-		stack;
+		goto_out;
 	r = 1;
 
       out:


