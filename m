From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Apr 2010 11:52:54 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/con ...
Message-ID: <20100412115254.13954.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-12 11:52:54

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	lib/config     : config.c 

Log message:
	Don't ignore error if resuming any LV fails in resume_lvs.
	Skip closing persistent filter cache file if open failed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1509&r2=1.1510
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/WHATS_NEW	2010/04/09 21:42:48	1.1509
+++ LVM2/WHATS_NEW	2010/04/12 11:52:53	1.1510
@@ -1,5 +1,7 @@
 Version 2.02.63 -  
 ================================
+  Don't ignore error if resuming any LV fails in resume_lvs.
+  Skip closing persistent filter cache file if open failed.
   Install .a .so links to $(usrlibdir).
   Add --enable-write_install options to install user writable files.
   Use INSTALL_PROGRAM/DATA/WDATA target.
--- LVM2/lib/locking/locking.c	2010/04/01 10:34:10	1.77
+++ LVM2/lib/locking/locking.c	2010/04/12 11:52:53	1.78
@@ -468,12 +468,15 @@
 int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs)
 {
 	struct lv_list *lvl;
+	int r = 1;
 
 	dm_list_iterate_items(lvl, lvs)
-		if (!resume_lv(cmd, lvl->lv))
+		if (!resume_lv(cmd, lvl->lv)) {
+			r = 0;
 			stack;
+		}
 
-	return 1;
+	return r;
 }
 
 /* Lock a list of LVs */
--- LVM2/lib/config/config.c	2010/04/01 10:34:09	1.78
+++ LVM2/lib/config/config.c	2010/04/12 11:52:53	1.79
@@ -295,8 +295,10 @@
 		if (!(c->dev = dev_create_file(c->filename, NULL, NULL, 1)))
 			return_0;
 
-		if (!dev_open_flags(c->dev, O_RDONLY, 0, 0))
+		if (!dev_open_flags(c->dev, O_RDONLY, 0, 0)) {
+			c->dev = 0;
 			return_0;
+		}
 	}
 
 	r = read_config_fd(cft, c->dev, 0, (size_t) info.st_size, 0, 0,


