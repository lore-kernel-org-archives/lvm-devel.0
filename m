From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 12:48:41 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110310124841.17655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 12:48:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 
	libdm/datastruct: hash.c 

Log message:
	Use void pointer instead of char for binary key
	
	dm_hash binary functions takes void* key - so there is no need to cast
	pointers to char* (also the hash key does not have trailing '\0').
	
	This is slight API change, but presents no change for the API user side
	it just allows to write code easier as the casting could be removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.454&r2=1.455
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.136&r2=1.137
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/hash.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW_DM	2011/03/08 22:43:19	1.454
+++ LVM2/WHATS_NEW_DM	2011/03/10 12:48:40	1.455
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Change dm_hash API for binary data to accept const void *key.
   Fix memory access of empty params string in _reload_with_suppression_v4().
   Lower severity of selabel_lookup and matchpathcon failure to log_debug.
   Accept multiple mapped device names on many dmsetup command lines.
--- LVM2/libdm/libdevmapper.h	2011/02/18 14:38:48	1.136
+++ LVM2/libdm/libdevmapper.h	2011/03/10 12:48:40	1.137
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -713,10 +713,10 @@
 int dm_hash_insert(struct dm_hash_table *t, const char *key, void *data);
 void dm_hash_remove(struct dm_hash_table *t, const char *key);
 
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const char *key, uint32_t len);
-int dm_hash_insert_binary(struct dm_hash_table *t, const char *key, uint32_t len,
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key, uint32_t len);
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key, uint32_t len,
 		       void *data);
-void dm_hash_remove_binary(struct dm_hash_table *t, const char *key, uint32_t len);
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key, uint32_t len);
 
 unsigned dm_hash_get_num_entries(struct dm_hash_table *t);
 void dm_hash_iter(struct dm_hash_table *t, dm_hash_iterate_fn f);
--- LVM2/libdm/datastruct/hash.c	2010/09/30 21:06:52	1.12
+++ LVM2/libdm/datastruct/hash.c	2011/03/10 12:48:41	1.13
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -133,7 +133,7 @@
 	dm_free(t);
 }
 
-static struct dm_hash_node **_find(struct dm_hash_table *t, const char *key,
+static struct dm_hash_node **_find(struct dm_hash_table *t, const void *key,
 				   uint32_t len)
 {
 	unsigned h = _hash(key, len) & (t->num_slots - 1);
@@ -150,15 +150,15 @@
 	return c;
 }
 
-void *dm_hash_lookup_binary(struct dm_hash_table *t, const char *key,
-			 uint32_t len)
+void *dm_hash_lookup_binary(struct dm_hash_table *t, const void *key,
+			    uint32_t len)
 {
 	struct dm_hash_node **c = _find(t, key, len);
 
 	return *c ? (*c)->data : 0;
 }
 
-int dm_hash_insert_binary(struct dm_hash_table *t, const char *key,
+int dm_hash_insert_binary(struct dm_hash_table *t, const void *key,
 			  uint32_t len, void *data)
 {
 	struct dm_hash_node **c = _find(t, key, len);
@@ -180,7 +180,7 @@
 	return 1;
 }
 
-void dm_hash_remove_binary(struct dm_hash_table *t, const char *key,
+void dm_hash_remove_binary(struct dm_hash_table *t, const void *key,
 			uint32_t len)
 {
 	struct dm_hash_node **c = _find(t, key, len);


