From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Jul 2010 02:09:59 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
Message-ID: <20100702020959.8357.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-02 02:09:57

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/commands   : toolcontext.c 
	lib/filters    : filter-persistent.c filter.c filter.h 

Log message:
	Always pass unsuspended dm devices through persistent filter to other filters.
	Move test for suspended dm devices ahead of other filters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1648&r2=1.1649
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2010/07/01 21:46:09	1.1648
+++ LVM2/WHATS_NEW	2010/07/02 02:09:57	1.1649
@@ -1,5 +1,7 @@
 Version 2.02.70 - 
 ================================
+  Always pass unsuspended dm devices through persistent filter to other filters.
+  Move test for suspended dm devices ahead of other filters.
   Fix another segfault in clvmd -R if no response from daemon received. (2.02.68)
   Remove superfluous suspended device counter from clvmd.
   Fix lvm shell crash when input is entirely whitespace.
--- LVM2/doc/example.conf.in	2010/06/30 14:04:15	1.4
+++ LVM2/doc/example.conf.in	2010/07/02 02:09:57	1.5
@@ -457,13 +457,15 @@
     # pvmetadatacopies = 1
 
     # Default number of copies of metadata to maintain for each VG.
-    # If set to a non-zero value, LVM automatically manages the PV
-    # 'metadataignore' flags (see pvchange) to achieve the requested
-    # copies of metadata.  You may set a value larger than the
-    # the sum of all metadata areas on all physical volumes.  This value
-    # can be overridden on the command line of various commands. The
-    # default value of 0 indicates that LVM should not automatically
-    # manage the 'metadataignore' flags.
+    # If set to a non-zero value, LVM automatically chooses which of
+    # the available metadata areas to use to achieve the requested
+    # number of copies of the VG metadata.  If you set a value larger
+    # than the the total number of metadata areas available then
+    # metadata is stored in them all.
+    # The default value of 0 ("unmanaged") disables this automatic
+    # management and allows you to control which metadata areas
+    # are used at the individual PV level using 'pvchange
+    # --metadataignore y/n'.
 
     # vgmetadatacopies = 0
 
--- LVM2/lib/commands/toolcontext.c	2010/06/01 21:47:57	1.100
+++ LVM2/lib/commands/toolcontext.c	2010/07/02 02:09:57	1.101
@@ -24,6 +24,7 @@
 #include "filter-md.h"
 #include "filter-persistent.h"
 #include "filter-regex.h"
+#include "filter-suspended.h"
 #include "filter-sysfs.h"
 #include "label.h"
 #include "lvm-file.h"
--- LVM2/lib/filters/filter-persistent.c	2010/06/01 19:02:12	1.42
+++ LVM2/lib/filters/filter-persistent.c	2010/07/02 02:09:57	1.43
@@ -16,9 +16,11 @@
 #include "lib.h"
 #include "config.h"
 #include "dev-cache.h"
+#include "filter.h"
 #include "filter-persistent.h"
 #include "lvm-file.h"
 #include "lvm-string.h"
+#include "activate.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -266,15 +268,31 @@
 	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
 	struct str_list *sl;
 
+	/* Cached BAD? */
+	if (l == PF_BAD_DEVICE) {
+		log_debug("%s: Skipping (cached)", dev_name(dev));
+		return 0;
+	}
+
+        /* Test dm devices every time, so cache them as GOOD. */
+	if (MAJOR(dev->dev) == dm_major()) {
+		if (!l)
+			dm_list_iterate_items(sl, &dev->aliases)
+				dm_hash_insert(pf->devices, sl->str, PF_GOOD_DEVICE);
+		if (ignore_suspended_devices() && !device_is_usable(dev)) {
+                	log_debug("%s: Skipping (suspended/internal)", dev_name(dev));
+			return 0;
+		}
+		return pf->real->passes_filter(pf->real, dev);
+	}
+
+	/* Uncached */
 	if (!l) {
-		l = pf->real->passes_filter(pf->real, dev) ?
-		    PF_GOOD_DEVICE : PF_BAD_DEVICE;
+		l = pf->real->passes_filter(pf->real, dev) ?  PF_GOOD_DEVICE : PF_BAD_DEVICE;
 
 		dm_list_iterate_items(sl, &dev->aliases)
 			dm_hash_insert(pf->devices, sl->str, l);
-
-	} else if (l == PF_BAD_DEVICE)
-			log_debug("%s: Skipping (cached)", dev_name(dev));
+	}
 
 	return (l == PF_BAD_DEVICE) ? 0 : 1;
 }
--- LVM2/lib/filters/filter.c	2010/05/17 18:39:03	1.53
+++ LVM2/lib/filters/filter.c	2010/07/02 02:09:57	1.54
@@ -42,6 +42,11 @@
 static int _drbd_major = -1;
 static int _device_mapper_major = -1;
 
+int dm_major(void)
+{
+	return _device_mapper_major;
+}
+
 int md_major(void)
 {
 	return _md_major;
@@ -130,14 +135,6 @@
 		return 0;
 	}
 
-	/* FIXME Always check 'layer' regardless of ignore_suspended_devices */
-	/* Skip suspended devices */
-	if (MAJOR(dev->dev) == _device_mapper_major &&
-	    ignore_suspended_devices() && !device_is_usable(dev)) {
-		log_debug("%s: Skipping: Suspended or internal dm device", name);
-		return 0;
-	}
-
 	/* Check it's accessible */
 	if (!dev_open_flags(dev, O_RDONLY, 0, 1)) {
 		log_debug("%s: Skipping: open failed", name);
--- LVM2/lib/filters/filter.h	2009/10/27 17:00:46	1.17
+++ LVM2/lib/filters/filter.h	2010/07/02 02:09:57	1.18
@@ -35,6 +35,7 @@
 
 void lvm_type_filter_destroy(struct dev_filter *f);
 
+int dm_major(void);
 int md_major(void);
 int blkext_major(void);
 int max_partitions(int major);


