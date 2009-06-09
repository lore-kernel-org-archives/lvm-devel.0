From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jun 2009 14:29:12 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090609142912.6297.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-09 14:29:11

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Add vg_lock_newname() library function.
	
	Various tools need to check for existence of a VG before doing something
	(vgsplit, vgrename, vgcreate).  Currently we don't have an interface to
	check for existence, but the existence check is part of the vg_read* call(s).
	This patch is an attempt to pull out some of that functionality into a
	separate function, and hopefully simplify our vg_read interface, and
	move those patches along.
	
	vg_lock_newname() is only concerned about checking whether a vg exists in
	the system.  Unfortunately, we cannot just scan the system, but we must first
	obtain a lock.  Since we are reserving a vgname, we take a WRITE lock on
	the vgname.  Once obtained, we scan the system to ensure the name does
	not exist.  The return codes and behavior is in the function header.
	You might think of this function as similar to an open() call with
	O_CREAT and O_EXCL flags (returns failure with -EEXIST if file already
	exists).
	
	NOTE: I think including the word "lock" in the function name is important,
	as it clearly states the function obtains a lock and makes the code more
	readable, especially when it comes to cleanup / unlocking.  The ultimate
	function name is somewhat open for debate though so later we may rename.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225

--- LVM2/lib/metadata/metadata-exported.h	2009/06/05 20:00:52	1.76
+++ LVM2/lib/metadata/metadata-exported.h	2009/06/09 14:29:10	1.77
@@ -127,6 +127,8 @@
 #define FAILED_RESIZEABLE	0x00000020U
 #define FAILED_CLUSTERED	0x00000040U
 #define FAILED_ALLOCATION	0x00000080U
+#define FAILED_EXIST		0x00000100U
+#define SUCCESS			0x00000000U
 
 /* Ordered list - see lv_manip.c */
 typedef enum {
@@ -401,6 +403,7 @@
 		       const char *vgid,
 		       uint32_t lock_flags, uint32_t status_flags,
 		       uint32_t misc_flags);
+uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname);
 
 /*
  * Return a handle to VG metadata.
--- LVM2/lib/metadata/metadata.c	2009/06/01 12:43:32	1.224
+++ LVM2/lib/metadata/metadata.c	2009/06/09 14:29:10	1.225
@@ -2909,6 +2909,52 @@
 }
 
 /*
+ * Lock a vgname and/or check for existence.
+ * Takes a WRITE lock on the vgname before scanning.
+ * If scanning fails or vgname found, release the lock.
+ * NOTE: If you find the return codes confusing, you might think of this
+ * function as similar to an open() call with O_CREAT and O_EXCL flags
+ * (open returns fail with -EEXIST if file already exists).
+ *
+ * Returns:
+ * FAILED_LOCKING - Cannot lock name
+ * FAILED_EXIST - VG name already exists - cannot reserve
+ * SUCCESS - VG name does not exist in system and WRITE lock held
+ */
+uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
+{
+	if (!lock_vol(cmd, vgname, LCK_VG_WRITE)) {
+		return FAILED_LOCKING;
+	}
+
+	/* Find the vgname in the cache */
+	/* If it's not there we must do full scan to be completely sure */
+	if (!fmt_from_vgname(vgname, NULL)) {
+		lvmcache_label_scan(cmd, 0);
+		if (!fmt_from_vgname(vgname, NULL)) {
+			if (memlock()) {
+				/*
+				 * FIXME: Disallow calling this function if
+				 * memlock() is true.
+				 */
+				unlock_vg(cmd, vgname);
+				return FAILED_LOCKING;
+			}
+			lvmcache_label_scan(cmd, 2);
+			if (!fmt_from_vgname(vgname, NULL)) {
+				/* vgname not found after scanning */
+				return SUCCESS;
+			}
+		}
+	}
+
+	/* Found vgname, cannot reserve */
+	unlock_vg(cmd, vgname);
+	return FAILED_EXIST;
+}
+
+
+/*
  * Gets/Sets for external LVM library
  */
 struct id pv_id(const pv_t *pv)


