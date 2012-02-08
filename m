From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 12:50:11 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/archiver.c
Message-ID: <20120208125011.21758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 12:50:11

Modified files:
	.              : WHATS_NEW 
	lib/format_text: archiver.c 

Log message:
	Use dm_snprintf and improve error handling
	
	Add standard error reporting with error logging.
	Use plain alloc instead of zalloc for string buffer.
	Use dm_snprintf with valid test for <0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2268&r2=1.2269
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW	2012/02/08 12:48:14	1.2268
+++ LVM2/WHATS_NEW	2012/02/08 12:50:10	1.2269
@@ -1,5 +1,6 @@
 Version 2.02.91 -
 ===================================
+  Fix error path handling in _build_desc()
   Add range test for device number in _scan_proc_dev().
   Use signed long for sysconf() call in cmirrord.
   Do not write in front of log buffer in print_log().
--- LVM2/lib/format_text/archiver.c	2012/01/20 11:01:13	1.48
+++ LVM2/lib/format_text/archiver.c	2012/02/08 12:50:10	1.49
@@ -83,13 +83,16 @@
 	size_t len = strlen(line) + 32;
 	char *buffer;
 
-	if (!(buffer = dm_pool_zalloc(mem, strlen(line) + 32)))
-		return_NULL;
+	if (!(buffer = dm_pool_alloc(mem, len))) {
+		log_error("Failed to allocate desc.");
+		return NULL;
+	}
 
-	if (snprintf(buffer, len,
-		     "Created %s executing '%s'",
-		     before ? "*before*" : "*after*", line) < 0)
-		return_NULL;
+	if (dm_snprintf(buffer, len, "Created %s executing '%s'",
+			before ? "*before*" : "*after*", line) < 0) {
+		log_error("Failed to build desc.");
+		return NULL;
+	}
 
 	return buffer;
 }


