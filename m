From: meyering@sourceware.org <meyering@sourceware.org>
Date: Fri, 20 Jul 2007 15:22:55 -0000
Subject: LVM2 ./WHATS_NEW lib/filters/filter-persistent ...
Message-ID: <20070720152247.5091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-20 15:22:46

Modified files:
	.              : WHATS_NEW 
	lib/filters    : filter-persistent.c 
	lib/locking    : file_locking.c 
	lib/misc       : lvm-file.h 

Log message:
	Introduce is_same_inode macro, now including a comparison of st_dev.
	
	* lib/misc/lvm-file.h (is_same_inode): Define.
	* lib/filters/filter-persistent.c (persistent_filter_dump): Use is_same_inode
	in place of a direct st_ino-only comparison.
	* lib/locking/file_locking.c (_release_lock, _lock_file): Likewise.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.662&r2=1.663
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter-persistent.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW	2007/07/20 12:12:52	1.662
+++ LVM2/WHATS_NEW	2007/07/20 15:22:45	1.663
@@ -1,5 +1,5 @@
 Version 2.02.28 -
-================================
+  Introduce is_same_inode macro, now including a comparison of st_dev.
   Don't leak a file descriptor in _lock_file(), when flock fails.
   Add SUN's LDOM virtual block device to filters
   Split metadata-external.h out from metadata.h for the tools to use.
--- LVM2/lib/filters/filter-persistent.c	2007/04/26 16:44:58	1.30
+++ LVM2/lib/filters/filter-persistent.c	2007/07/20 15:22:45	1.31
@@ -208,7 +208,7 @@
 			goto out;
 		}
 
-		if (!memcmp(&info.st_ino, &info2.st_ino, sizeof(ino_t)))
+		if (is_same_inode(info, info2))
 			break;
 	
 		fcntl_unlock_file(lockfd);
--- LVM2/lib/locking/file_locking.c	2007/07/20 12:12:52	1.27
+++ LVM2/lib/locking/file_locking.c	2007/07/20 15:22:46	1.28
@@ -64,7 +64,7 @@
 			if (!flock(ll->lf, LOCK_NB | LOCK_EX) &&
 			    !stat(ll->res, &buf1) &&
 			    !fstat(ll->lf, &buf2) &&
-			    !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
+			    is_same_inode(buf1, buf2))
 				if (unlink(ll->res))
 					log_sys_error("unlink", ll->res);
 
@@ -190,7 +190,7 @@
 		}
 
 		if (!stat(ll->res, &buf1) && !fstat(ll->lf, &buf2) &&
-		    !memcmp(&buf1.st_ino, &buf2.st_ino, sizeof(ino_t)))
+		    is_same_inode(buf1, buf2))
 			break;
 	} while (!(flags & LCK_NONBLOCK));
 
--- LVM2/lib/misc/lvm-file.h	2006/11/04 03:34:10	1.8
+++ LVM2/lib/misc/lvm-file.h	2007/07/20 15:22:46	1.9
@@ -52,4 +52,8 @@
 int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only);
 void fcntl_unlock_file(int lockfd);
 
+#define is_same_inode(buf1, buf2) \
+  ((buf1).st_ino == (buf2).st_ino && \
+   (buf1).st_dev == (buf2).st_dev)
+
 #endif


