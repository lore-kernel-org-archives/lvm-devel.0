From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 13:14:55 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20111221131455.8685.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 13:14:54

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Always zalloc device structure
	
	Since there is zalloc behind the macro, put 'z' into the name.
	Make the 'use_malloc' code path also using zalloc() call,
	so it also give zeroed area.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2209&r2=1.2210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2011/12/21 13:03:06	1.2209
+++ LVM2/WHATS_NEW	2011/12/21 13:14:54	1.2210
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Always zalloc device structure during initialization.
   Fix missing thread list manipulation protection in dmeventd.
   Do not derefence lv pointer in _percent_run() function before NULL check.
   Allow empty strings for description and creation_host config fields.
--- LVM2/lib/device/dev-cache.c	2011/08/30 14:55:16	1.66
+++ LVM2/lib/device/dev-cache.c	2011/12/21 13:14:54	1.67
@@ -48,7 +48,7 @@
 
 } _cache;
 
-#define _alloc(x) dm_pool_zalloc(_cache.mem, (x))
+#define _zalloc(x) dm_pool_zalloc(_cache.mem, (x))
 #define _free(x) dm_pool_free(_cache.mem, (x))
 #define _strdup(x) dm_pool_strdup(_cache.mem, (x))
 
@@ -61,11 +61,11 @@
 
 	if (allocate) {
 		if (use_malloc) {
-			if (!(dev = dm_malloc(sizeof(*dev)))) {
+			if (!(dev = dm_zalloc(sizeof(*dev)))) {
 				log_error("struct device allocation failed");
 				return NULL;
 			}
-			if (!(alias = dm_malloc(sizeof(*alias)))) {
+			if (!(alias = dm_zalloc(sizeof(*alias)))) {
 				log_error("struct str_list allocation failed");
 				dm_free(dev);
 				return NULL;
@@ -78,11 +78,11 @@
 			}
 			dev->flags = DEV_ALLOCED;
 		} else {
-			if (!(dev = _alloc(sizeof(*dev)))) {
+			if (!(dev = _zalloc(sizeof(*dev)))) {
 				log_error("struct device allocation failed");
 				return NULL;
 			}
-			if (!(alias = _alloc(sizeof(*alias)))) {
+			if (!(alias = _zalloc(sizeof(*alias)))) {
 				log_error("struct str_list allocation failed");
 				_free(dev);
 				return NULL;
@@ -118,7 +118,7 @@
 {
 	struct device *dev;
 
-	if (!(dev = _alloc(sizeof(*dev)))) {
+	if (!(dev = _zalloc(sizeof(*dev)))) {
 		log_error("struct device allocation failed");
 		return NULL;
 	}
@@ -303,7 +303,7 @@
 
 static int _add_alias(struct device *dev, const char *path)
 {
-	struct str_list *sl = _alloc(sizeof(*sl));
+	struct str_list *sl = _zalloc(sizeof(*sl));
 	struct str_list *strl;
 	const char *oldpath;
 	int prefer_old = 1;
@@ -788,7 +788,7 @@
 		return 1;
 	}
 
-	if (!(dl = _alloc(sizeof(*dl) + strlen(path) + 1))) {
+	if (!(dl = _zalloc(sizeof(*dl) + strlen(path) + 1))) {
 		log_error("dir_list allocation failed");
 		return 0;
 	}
@@ -814,7 +814,7 @@
 		return 1;
 	}
 
-	if (!(dl = _alloc(sizeof(*dl) + strlen(path) + 1))) {
+	if (!(dl = _zalloc(sizeof(*dl) + strlen(path) + 1))) {
 		log_error("dir_list allocation failed for file");
 		return 0;
 	}


