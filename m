From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Apr 2010 12:31:35 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-regex.c
Message-ID: <20100430123135.21822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-30 12:31:33

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-regex.c 

Log message:
	Show string with invalid pattern
	and start error message with capital letter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1542&r2=1.1543
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-regex.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2010/04/29 01:45:30	1.1542
+++ LVM2/WHATS_NEW	2010/04/30 12:31:32	1.1543
@@ -1,5 +1,6 @@
 Version 2.02.64 -
 =================================
+  Display invalid regex pattern for filter configuration in case of error.
   Remove no-longer-used arg_ptr_value.
   Fix -M and --type to use strings not pointers that change on config refresh.
   Fix lvconvert error message when existing mirrored LV is not found.
--- LVM2/lib/filters/filter-regex.c	2008/11/03 22:14:28	1.26
+++ LVM2/lib/filters/filter-regex.c	2010/04/30 12:31:33	1.27
@@ -103,7 +103,7 @@
 	 */
 	for (v = val; v; v = v->next) {
 		if (v->type != CFG_STRING) {
-			log_error("filter patterns must be enclosed in quotes");
+			log_error("Filter patterns must be enclosed in quotes.");
 			goto out;
 		}
 
@@ -128,7 +128,7 @@
 	 */
 	for (v = val, i = count - 1; v; v = v->next, i--)
 		if (!_extract_pattern(scratch, v->v.str, regex, rf->accept, i)) {
-			log_error("invalid filter pattern");
+			log_error("Invalid filter pattern \"%s\".", v->v.str);
 			goto out;
 		}
 


