From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:47:46 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20111221124746.8469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:47:45

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-config.c 

Log message:
	Add dm_config_find_str_allow_empty
	
	Support empty string values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.525&r2=1.526
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW_DM	2011/12/07 12:29:41	1.525
+++ LVM2/WHATS_NEW_DM	2011/12/21 12:47:44	1.526
@@ -6,7 +6,7 @@
   Improve man page style for dmsetup.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
-  Add dm_config_tree_find_str_allow_empty.
+  Add dm_config_tree_find_str_allow_empty and dm_config_find_str_allow_empty.
   Fix compile-time pool memory locking with DEBUG_MEM.
   Fix valgrind error reports in free of pool chunks with DEBUG_MEM.
   Align size of structure chunk for fast pool allocator to 8 bytes.
--- LVM2/libdm/libdevmapper.h	2011/12/18 21:56:03	1.171
+++ LVM2/libdm/libdevmapper.h	2011/12/21 12:47:45	1.172
@@ -1351,6 +1351,7 @@
 struct dm_config_node *dm_config_find_node(struct dm_config_node *cn, const char *path);
 int dm_config_has_node(const struct dm_config_node *cn, const char *path);
 const char *dm_config_find_str(const struct dm_config_node *cn, const char *path, const char *fail);
+const char *dm_config_find_str_allow_empty(const struct dm_config_node *cn, const char *path, const char *fail);
 int dm_config_find_int(const struct dm_config_node *cn, const char *path, int fail);
 float dm_config_find_float(const struct dm_config_node *cn, const char *path, float fail);
 
--- LVM2/libdm/libdm-config.c	2011/12/18 21:56:03	1.18
+++ LVM2/libdm/libdm-config.c	2011/12/21 12:47:45	1.19
@@ -772,6 +772,12 @@
 	return _find_config_str(cn, _find_config_node, path, fail, 0);
 }
 
+const char *dm_config_find_str_allow_empty(const struct dm_config_node *cn,
+					   const char *path, const char *fail)
+{
+	return _find_config_str(cn, _find_config_node, path, fail, 1);
+}
+
 static int64_t _find_config_int64(const void *start, node_lookup_fn find,
 				  const char *path, int64_t fail)
 {


