From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 12 Oct 2009 04:06:43 -0000
Subject: LVM2 ./WHATS_NEW_DM lib/activate/fs.c libdm/li ...
Message-ID: <20091012040643.16710.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2009-10-12 04:06:42

Modified files:
	.              : WHATS_NEW_DM 
	lib/activate   : fs.c 
	libdm          : libdm-common.c 

Log message:
	Merge Debian patch 05 debian: keep libdm-abi consistent.
	
	This appears to be the only user visible feature that can change libdm ABI
	at build time.
	
	Thanks to Bastian Blank for the patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.304&r2=1.305
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW_DM	2009/09/26 00:42:47	1.304
+++ LVM2/WHATS_NEW_DM	2009/10/12 04:06:42	1.305
@@ -1,5 +1,6 @@
 Version 1.02.39 - 
 =====================================
+  Make libdm ABI consistent when built with/without selinux support.
 
 Version 1.02.38 - 25th September 2009
 =====================================
--- LVM2/lib/activate/fs.c	2009/09/25 11:58:00	1.48
+++ LVM2/lib/activate/fs.c	2009/10/12 04:06:42	1.49
@@ -201,10 +201,8 @@
 		return 0;
 	}
 
-#ifdef HAVE_SELINUX
 	if (!dm_set_selinux_context(lv_path, S_IFLNK))
 		return_0;
-#endif
 
 	return 1;
 }
--- LVM2/libdm/libdm-common.c	2009/09/25 19:06:05	1.85
+++ LVM2/libdm/libdm-common.c	2009/10/12 04:06:42	1.86
@@ -373,9 +373,9 @@
 	return 1;
 }
 
-#ifdef HAVE_SELINUX
 int dm_set_selinux_context(const char *path, mode_t mode)
 {
+#ifdef HAVE_SELINUX
 	security_context_t scontext;
 
 	if (is_selinux_enabled() <= 0)
@@ -396,9 +396,9 @@
 	}
 
 	freecon(scontext);
+#endif
 	return 1;
 }
-#endif
 
 static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 			 uid_t uid, gid_t gid, mode_t mode)
@@ -445,10 +445,8 @@
 
 	log_debug("Created %s", path);
 
-#ifdef HAVE_SELINUX
 	if (!dm_set_selinux_context(path, S_IFBLK))
 		return 0;
-#endif
 
 	return 1;
 }


