From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Mar 2012 19:54:55 -0000
Subject: LVM2 libdm/libdevmapper.h libdm/libdm-config.c ...
Message-ID: <20120301195455.30827.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-01 19:54:53

Modified files:
	libdm          : libdevmapper.h libdm-config.c 
	libdaemon/client: daemon-client.h 

Log message:
	Use 64 bit integers whenever extracting numbers from daemon replies.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdaemon/client/daemon-client.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/libdm/libdevmapper.h	2012/02/23 22:45:43	1.184
+++ LVM2/libdm/libdevmapper.h	2012/03/01 19:54:53	1.185
@@ -1453,6 +1453,7 @@
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
 const char *dm_config_find_str_allow_empty(const struct dm_config_node *cn, const char *path, const char *fail);
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
+int64_t dm_config_find_int64(const struct dm_config_node *cn, const char *path, int64_t fail);
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
 
 const struct dm_config_node *dm_config_tree_find_node(const struct dm_config_tree *cft, const char *path);
--- LVM2/libdm/libdm-config.c	2012/02/28 17:46:47	1.22
+++ LVM2/libdm/libdm-config.c	2012/03/01 19:54:53	1.23
@@ -877,6 +877,11 @@
 	return (int) _find_config_int64(cn, _find_config_node, path, (int64_t) fail);
 }
 
+int64_t dm_config_find_int64(const struct dm_config_node *cn, const char *path, int64_t fail)
+{
+	return _find_config_int64(cn, _find_config_node, path, fail);
+}
+
 float dm_config_find_float(const struct dm_config_node *cn, const char *path,
 			   float fail)
 {
--- LVM2/libdaemon/client/daemon-client.h	2012/02/28 18:35:05	1.2
+++ LVM2/libdaemon/client/daemon-client.h	2012/03/01 19:54:53	1.3
@@ -90,8 +90,8 @@
 
 void daemon_reply_destroy(daemon_reply r);
 
-static inline int daemon_reply_int(daemon_reply r, const char *path, int def) {
-	return dm_config_find_int(r.cft->root, path, def);
+static inline int64_t daemon_reply_int(daemon_reply r, const char *path, int64_t def) {
+	return dm_config_find_int64(r.cft->root, path, def);
 }
 
 static inline const char *daemon_reply_str(daemon_reply r, const char *path, const char *def) {


