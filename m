From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 13:09:23 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archive.c
Message-ID: <20100803130923.6795.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 13:09:22

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archive.c 

Log message:
	Fix constness warning in archive_file structure from archive.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1689&r2=1.1690
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2010/08/03 13:00:45	1.1689
+++ LVM2/WHATS_NEW	2010/08/03 13:09:21	1.1690
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix constness warning in archive_file structure from archive.c.
   Clean generated files .exported_symbols_generated, example.conf for distclean.
   Handle failure of all mirrored log devices and all but one mirror leg. 
   Disallow 'mirrored' log type for cluster mirrors.
--- LVM2/lib/format_text/archive.c	2009/12/03 19:18:33	1.37
+++ LVM2/lib/format_text/archive.c	2010/08/03 13:09:22	1.38
@@ -50,7 +50,7 @@
 struct archive_file {
 	struct dm_list list;
 
-	char *path;
+	const char *path;
 	uint32_t index;
 };
 
@@ -353,7 +353,7 @@
 {
 	struct archive_file af;
 
-	af.path = (char *)file;
+	af.path = file;
 
 	if (!path_exists(af.path)) {
 		log_error("Archive file %s not found.", af.path);


