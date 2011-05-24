From: agk@sourceware.org <agk@sourceware.org>
Date: 24 May 2011 13:36:59 -0000
Subject: LVM2 ./WHATS_NEW lib/config/config.c lib/devic ...
Message-ID: <20110524133659.32272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-05-24 13:36:58

Modified files:
	.              : WHATS_NEW 
	lib/config     : config.c 
	lib/device     : dev-io.c device.h 
	lib/filters    : filter.c 

Log message:
	Add and use dev_open_readonly and variations.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1990&r2=1.1991
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-io.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/WHATS_NEW	2011/05/19 13:59:23	1.1990
+++ LVM2/WHATS_NEW	2011/05/24 13:36:57	1.1991
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Add and use dev_open_readonly and variations.
   Do not log a superfluous stack message when the lv is properly processed.
   Do not issue an error message when unable to remove .cache on read-only fs.
   Avoid memlock size mismatch by preallocating stdio line buffers.
--- LVM2/lib/config/config.c	2011/03/10 14:51:35	1.91
+++ LVM2/lib/config/config.c	2011/05/24 13:36:57	1.92
@@ -295,7 +295,7 @@
 		if (!(c->dev = dev_create_file(c->filename, NULL, NULL, 1)))
 			return_0;
 
-		if (!dev_open_flags(c->dev, O_RDONLY, 0, 0)) {
+		if (!dev_open_readonly_buffered(c->dev)) {
 			c->dev = 0;
 			return_0;
 		}
--- LVM2/lib/device/dev-io.c	2011/04/12 21:59:01	1.76
+++ LVM2/lib/device/dev-io.c	2011/05/24 13:36:57	1.77
@@ -556,6 +556,21 @@
 	return dev_open_flags(dev, flags, 1, 0);
 }
 
+int dev_open_readonly(struct device *dev)
+{
+	return dev_open_flags(dev, O_RDONLY, 1, 0);
+}
+
+int dev_open_readonly_buffered(struct device *dev)
+{
+	return dev_open_flags(dev, O_RDONLY, 0, 0);
+}
+
+int dev_open_readonly_quiet(struct device *dev)
+{
+	return dev_open_flags(dev, O_RDONLY, 1, 1);
+}
+
 int dev_test_excl(struct device *dev)
 {
 	int flags;
--- LVM2/lib/device/device.h	2011/04/12 21:59:01	1.48
+++ LVM2/lib/device/device.h	2011/05/24 13:36:57	1.49
@@ -74,6 +74,9 @@
 int dev_open(struct device *dev);
 int dev_open_quiet(struct device *dev);
 int dev_open_flags(struct device *dev, int flags, int direct, int quiet);
+int dev_open_readonly(struct device *dev);
+int dev_open_readonly_buffered(struct device *dev);
+int dev_open_readonly_quiet(struct device *dev);
 int dev_close(struct device *dev);
 int dev_close_immediate(struct device *dev);
 void dev_close_all(void);
--- LVM2/lib/filters/filter.c	2011/02/18 14:11:23	1.61
+++ LVM2/lib/filters/filter.c	2011/05/24 13:36:58	1.62
@@ -147,7 +147,7 @@
 	}
 
 	/* Check it's accessible */
-	if (!dev_open_flags(dev, O_RDONLY, 1, 1)) {
+	if (!dev_open_readonly_quiet(dev)) {
 		log_debug("%s: Skipping: open failed", name);
 		return 0;
 	}


