From: meyering@sourceware.org <meyering@sourceware.org>
Date: 24 Jul 2007 17:48:09 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/filte ...
Message-ID: <20070724174809.31459.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-24 17:48:08

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/filters    : filter-persistent.c 
	lib/format_text: archive.c format-text.c 
	lib/log        : log.c 
	lib/misc       : lvm-file.c lvm-file.h 

Log message:
	Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
	* lib/misc/lvm-file.c (lvm_fclose): New function.
	* lib/misc/lvm-file.h (lvm_fclose): Declare it.
	* lib/config/config.c (write_config_file): Use the new function to detect
	and diagnose unlikely write failure.
	* lib/filters/filter-persistent.c (persistent_filter_dump): Likewise.
	* lib/format_text/archive.c (archive_vg): Likewise.
	* lib/format_text/format-text.c (_vg_write_file): Likewise.
	* lib/log/log.c (fin_log): Similar, but use dm_fclose directly.
	Include "\n" at end of each fprintf format string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.670&r2=1.671
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archive.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2007/07/24 15:35:11	1.670
+++ LVM2/WHATS_NEW	2007/07/24 17:48:07	1.671
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
   Fix clvmd if compiled with gulm support. (2.02.26)
   Trivial fix to lvdisplay man page.
   Add vg_lock_and_read() external library function.
--- LVM2/lib/config/config.c	2007/07/20 15:38:19	1.62
+++ LVM2/lib/config/config.c	2007/07/24 17:48:07	1.63
@@ -20,6 +20,7 @@
 #include "str_list.h"
 #include "toolcontext.h"
 #include "lvm-string.h"
+#include "lvm-file.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
@@ -520,8 +521,8 @@
 		argv++;
 	}
 
-	if (outline.fp && fclose(outline.fp)) {
-		log_sys_error("fclose", file);
+	if (outline.fp && lvm_fclose(outline.fp, file)) {
+		stack;
 		r = 0;
 	}
 
--- LVM2/lib/filters/filter-persistent.c	2007/07/20 15:22:45	1.31
+++ LVM2/lib/filters/filter-persistent.c	2007/07/24 17:48:08	1.32
@@ -239,10 +239,8 @@
 	/* _write_array(pf, fp, "invalid_devices", PF_BAD_DEVICE); */
 
 	fprintf(fp, "}\n");
-	if (fclose(fp)) {
-		log_sys_error("fclose", tmp_file);
-		goto out;
-	}
+	if (lvm_fclose(fp, tmp_file))
+		goto_out;
 
 	if (rename(tmp_file, pf->file))
 		log_error("%s: rename to %s failed: %s", tmp_file, pf->file,
--- LVM2/lib/format_text/archive.c	2007/07/02 11:17:21	1.27
+++ LVM2/lib/format_text/archive.c	2007/07/24 17:48:08	1.28
@@ -261,11 +261,8 @@
 		return 0;
 	}
 
-	if (fclose(fp)) {
-		log_sys_error("fclose", temp_file);
-		/* Leave file behind as evidence of failure */
-		return 0;
-	}
+	if (lvm_fclose(fp, temp_file))
+		return_0; /* Leave file behind as evidence of failure */
 
 	/*
 	 * Now we want to rename this file to <vg>_index.vg.
--- LVM2/lib/format_text/format-text.c	2007/07/02 11:17:21	1.77
+++ LVM2/lib/format_text/format-text.c	2007/07/24 17:48:08	1.78
@@ -892,10 +892,8 @@
 		return 0;
 	}
 
-	if (fclose(fp)) {
-		log_sys_error("fclose", tc->path_edit);
-		return 0;
-	}
+	if (lvm_fclose(fp, tc->path_edit))
+		return_0;
 
 	if (rename(temp_file, tc->path_edit)) {
 		log_debug("Renaming %s to %s", temp_file, tc->path_edit);
--- LVM2/lib/log/log.c	2007/06/28 17:33:44	1.39
+++ LVM2/lib/log/log.c	2007/07/24 17:48:08	1.40
@@ -17,6 +17,7 @@
 #include "device.h"
 #include "memlock.h"
 #include "lvm-string.h"
+#include "lvm-file.h"
 #include "defaults.h"
 
 #include <stdarg.h>
@@ -121,8 +122,14 @@
 	}
 
 	if (_log_to_file) {
-		if (fclose(_log_file))
-			fprintf(stderr, "fclose() on log file failed: %s", strerror(errno));
+		if (dm_fclose(_log_file)) {
+			if (errno)
+			      fprintf(stderr, "failed to write log file: %s\n",
+				      strerror(errno));
+			else
+			      fprintf(stderr, "failed to write log file\n");
+
+		}
 		_log_to_file = 0;
 	}
 }
--- LVM2/lib/misc/lvm-file.c	2007/04/26 16:44:59	1.20
+++ LVM2/lib/misc/lvm-file.c	2007/07/24 17:48:08	1.21
@@ -321,3 +321,13 @@
 			  strerror(errno));
 }
 
+int lvm_fclose(FILE *fp, const char *filename)
+{
+	if (!dm_fclose(fp))
+		return 0;
+	if (errno == 0)
+		log_error("%s: write error", filename);
+	else
+		log_sys_error("write error", filename);
+	return EOF;
+}
--- LVM2/lib/misc/lvm-file.h	2007/07/20 15:22:46	1.9
+++ LVM2/lib/misc/lvm-file.h	2007/07/24 17:48:08	1.10
@@ -56,4 +56,13 @@
   ((buf1).st_ino == (buf2).st_ino && \
    (buf1).st_dev == (buf2).st_dev)
 
+/*
+ * Close the specified stream, taking care to detect and diagnose any write
+ * error.  If there is an error, use the supplied file name in a diagnostic
+ * that is reported via log_error or log_sys_error, as appropriate.
+ * Use this function to close a stream when you've written data to it via
+ * unchecked fprintf, fputc, etc. calls.  Return 0 on success, EOF on failure.
+ */
+int lvm_fclose(FILE *fp, const char *filename);
+
 #endif


