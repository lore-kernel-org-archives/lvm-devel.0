From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 14:02:08 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110901140208.7987.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 14:02:07

Modified files:
	libdm          : libdm-config.c 

Log message:
	Use const casting when it's needed
	
	Keep the lookup operation const and use const casting at the dm_ function level.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/libdm/libdm-config.c	2011/08/31 15:19:20	1.3
+++ LVM2/libdm/libdm-config.c	2011/09/01 14:02:05	1.4
@@ -809,8 +809,8 @@
 /*
  * utility functions
  */
-static struct dm_config_node *_find_config_node(const void *start,
-						const char *path)
+static const struct dm_config_node *_find_config_node(const void *start,
+						      const char *path)
 {
 	const char *e;
 	const struct dm_config_node *cn = start;
@@ -848,15 +848,15 @@
 		path = e;
 	}
 
-	return (struct dm_config_node *) cn_found;
+	return cn_found;
 }
 
-typedef struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
+typedef const struct dm_config_node *_node_lookup_fn(const void *start, const char *path);
 
-static struct dm_config_node *_find_first_config_node(const void *start, const char *path)
+static const struct dm_config_node *_find_first_config_node(const void *start, const char *path)
 {
 	const struct dm_config_tree *cft = start;
-	struct dm_config_node *cn = NULL;
+	const struct dm_config_node *cn = NULL;
 
 	while (cft) {
 		if ((cn = _find_config_node(cft->root, path)))
@@ -976,7 +976,7 @@
 struct dm_config_node *dm_config_find_node(struct dm_config_node *cn,
 					   const char *path)
 {
-	return _find_config_node(cn, path);
+	return (struct dm_config_node *) _find_config_node(cn, path);
 }
 
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail)


