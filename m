From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:17:54 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20111221131754.9797.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:17:54

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Add common initialization code for struct device
	
	Avoid duplicate code and add _dev_init() where all common
	member values are initialized.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2210&r2=1.2211
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2011/12/21 13:14:54	1.2210
+++ LVM2/WHATS_NEW	2011/12/21 13:17:54	1.2211
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add function to inialize common structure device members.
   Always zalloc device structure during initialization.
   Fix missing thread list manipulation protection in dmeventd.
   Do not derefence lv pointer in _percent_run() function before NULL check.
--- LVM2/lib/device/dev-cache.c	2011/12/21 13:14:54	1.67
+++ LVM2/lib/device/dev-cache.c	2011/12/21 13:17:54	1.68
@@ -54,6 +54,18 @@
 
 static int _insert(const char *path, int rec, int check_with_udev_db);
 
+/* Setup non-zero members of passed zeroed 'struct device' */
+static void _dev_init(struct device *dev, int max_error_count)
+{
+	dev->block_size = -1;
+	dev->fd = -1;
+	dev->read_ahead = -1;
+	dev->max_error_count = max_error_count;
+
+	dm_list_init(&dev->aliases);
+	dm_list_init(&dev->open_list);
+}
+
 struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct str_list *alias, int use_malloc)
 {
@@ -76,7 +88,6 @@
 				dm_free(alias);
 				return NULL;
 			}
-			dev->flags = DEV_ALLOCED;
 		} else {
 			if (!(dev = _zalloc(sizeof(*dev)))) {
 				log_error("struct device allocation failed");
@@ -97,19 +108,9 @@
 		return NULL;
 	}
 
-	dev->flags |= DEV_REGULAR;
-	dm_list_init(&dev->aliases);
+	_dev_init(dev, NO_DEV_ERROR_COUNT_LIMIT);
+	dev->flags = DEV_REGULAR | ((use_malloc) ? DEV_ALLOCED : 0);
 	dm_list_add(&dev->aliases, &alias->list);
-	dev->end = UINT64_C(0);
-	dev->dev = 0;
-	dev->fd = -1;
-	dev->open_count = 0;
-	dev->error_count = 0;
-	dev->max_error_count = NO_DEV_ERROR_COUNT_LIMIT;
-	dev->block_size = -1;
-	dev->read_ahead = -1;
-	memset(dev->pvid, 0, sizeof(dev->pvid));
-	dm_list_init(&dev->open_list);
 
 	return dev;
 }
@@ -122,17 +123,9 @@
 		log_error("struct device allocation failed");
 		return NULL;
 	}
-	dev->flags = 0;
-	dm_list_init(&dev->aliases);
+
+	_dev_init(dev, dev_disable_after_error_count());
 	dev->dev = d;
-	dev->fd = -1;
-	dev->open_count = 0;
-	dev->max_error_count = dev_disable_after_error_count();
-	dev->block_size = -1;
-	dev->read_ahead = -1;
-	dev->end = UINT64_C(0);
-	memset(dev->pvid, 0, sizeof(dev->pvid));
-	dm_list_init(&dev->open_list);
 
 	return dev;
 }


