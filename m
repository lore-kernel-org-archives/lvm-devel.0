From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Nov 2010 22:23:37 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c
Message-ID: <20101130222337.8129.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-30 22:23:35

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 

Log message:
	Add missing test for failed pool allocation
	
	Add test for NULL from dm_poll_create.
	Reorder dm_pool_destroy() before file close and add label out:.
	Avoid leaking file descriptor if the allocation fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1816&r2=1.1817
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/WHATS_NEW	2010/11/30 22:16:25	1.1816
+++ LVM2/WHATS_NEW	2010/11/30 22:23:35	1.1817
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add missing test for failed pool allocation in write_config_node().
   Replace snprintf with dm_snprintf in clvmd-command.c.
   Check reallocated buffer for NULL before use in clvmd do_command().
   Fix memory leak when VG allocation policy in metadata is invalid.
--- LVM2/lib/config/config.c	2010/11/23 15:08:57	1.83
+++ LVM2/lib/config/config.c	2010/11/30 22:23:35	1.84
@@ -511,7 +511,8 @@
 {
 	struct output_line outline;
 	outline.fp = NULL;
-	outline.mem = dm_pool_create("config_line", 1024);
+	if (!(outline.mem = dm_pool_create("config_line", 1024)))
+		return_0;
 	outline.putline = putline;
 	outline.putline_baton = baton;
 	if (!_write_config(cn, 0, &outline, 0)) {
@@ -538,7 +539,10 @@
 		return 0;
 	}
 
-	outline.mem = dm_pool_create("config_line", 1024);
+	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
+		r = 0;
+		goto_out;
+	}
 
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
@@ -559,12 +563,14 @@
 		argv++;
 	}
 
+	dm_pool_destroy(outline.mem);
+
+out:
 	if (outline.fp && lvm_fclose(outline.fp, file)) {
 		stack;
 		r = 0;
 	}
 
-	dm_pool_destroy(outline.mem);
 	return r;
 }
 


