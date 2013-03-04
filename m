From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 4 Mar 2013 18:32:38 -0500 (EST)
Subject: [PATCH] lvm locking: fix locking and move common code to does_file_refer_to_fd
Message-ID: <Pine.LNX.4.64.1303041831000.621@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm locking: fix locking and move common code to does_file_refer_to_fd

This creates a new function "does_file_refer_to_fd" that tests if the
specified path refers to a specified file descriptor.

The patch also adds a test if st_nlink is 0. In this case we know that
the file is unlinked and there is no need to check inode numbers
(because inode numbers may not be unique).

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/filters/filter-persistent.c |   13 ++-----------
 lib/locking/file_locking.c      |   10 ++--------
 lib/misc/lvm-file.c             |   17 +++++++++++++++++
 lib/misc/lvm-file.h             |    6 ++----
 4 files changed, 23 insertions(+), 23 deletions(-)

Index: lvm2-copy/lib/filters/filter-persistent.c
===================================================================
--- lvm2-copy.orig/lib/filters/filter-persistent.c	2013-03-04 23:48:16.000000000 +0100
+++ lvm2-copy/lib/filters/filter-persistent.c	2013-03-04 23:49:32.000000000 +0100
@@ -216,18 +216,9 @@ int persistent_filter_dump(struct dev_fi
 		/*
 		 * Ensure we locked the file we expected
 		 */
-		if (fstat(lockfd, &info)) {
-			log_sys_error("fstat", pf->file);
-			goto out;
-		}
-		if (stat(pf->file, &info2)) {
-			log_sys_error("stat", pf->file);
-			goto out;
-		}
-
-		if (is_same_inode(info, info2))
+		if (does_file_refer_to_fd(pf->file, lockfd))
 			break;
-	
+
 		fcntl_unlock_file(lockfd);
 	}
 
Index: lvm2-copy/lib/locking/file_locking.c
===================================================================
--- lvm2-copy.orig/lib/locking/file_locking.c	2013-03-04 23:44:54.000000000 +0100
+++ lvm2-copy/lib/locking/file_locking.c	2013-03-04 23:46:24.000000000 +0100
@@ -46,13 +46,9 @@ static volatile sig_atomic_t _handler_in
 
 static void _undo_flock(const char *file, int fd)
 {
-	struct stat buf1, buf2;
-
 	log_debug_locking("_undo_flock %s", file);
 	if (!flock(fd, LOCK_NB | LOCK_EX) &&
-	    !stat(file, &buf1) &&
-	    !fstat(fd, &buf2) &&
-	    is_same_inode(buf1, buf2))
+	    does_file_refer_to_fd(file, fd))
 		if (unlink(file))
 			log_sys_error("unlink", file);
 
@@ -135,7 +131,6 @@ static int _do_flock(const char *file, i
 {
 	int r = 1;
 	int old_errno;
-	struct stat buf1, buf2;
 
 	log_debug_locking("_do_flock %s %c%c", file,
 			  operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
@@ -166,8 +161,7 @@ static int _do_flock(const char *file, i
 			return 0;
 		}
 
-		if (!stat(file, &buf1) && !fstat(*fd, &buf2) &&
-		    is_same_inode(buf1, buf2))
+		if (does_file_refer_to_fd(file, *fd))
 			return 1;
 	} while (!nonblock);
 
Index: lvm2-copy/lib/misc/lvm-file.c
===================================================================
--- lvm2-copy.orig/lib/misc/lvm-file.c	2013-03-04 23:39:56.000000000 +0100
+++ lvm2-copy/lib/misc/lvm-file.c	2013-03-05 00:28:42.000000000 +0100
@@ -290,3 +290,20 @@ int lvm_fclose(FILE *fp, const char *fil
 		log_sys_error("write error", filename);
 	return EOF;
 }
+
+int does_file_refer_to_fd(const char *filename, int fd)
+{
+	struct stat buf1, buf2;
+
+	if (fstat(fd, &buf1)) {
+		log_sys_error("fstat", filename);
+		return 0;
+	}
+	if (!buf1.st_nlink)
+		return 0;
+
+	if (stat(filename, &buf2))
+		return 0;
+
+	return buf1.st_dev == buf2.st_dev && buf1.st_ino == buf2.st_ino;
+}
Index: lvm2-copy/lib/misc/lvm-file.h
===================================================================
--- lvm2-copy.orig/lib/misc/lvm-file.h	2013-03-04 23:44:27.000000000 +0100
+++ lvm2-copy/lib/misc/lvm-file.h	2013-03-04 23:45:31.000000000 +0100
@@ -47,10 +47,6 @@ void sync_dir(const char *file);
 int fcntl_lock_file(const char *file, short lock_type, int warn_if_read_only);
 void fcntl_unlock_file(int lockfd);
 
-#define is_same_inode(buf1, buf2) \
-  ((buf1).st_ino == (buf2).st_ino && \
-   (buf1).st_dev == (buf2).st_dev)
-
 #define is_valid_fd(fd) (!(fcntl(fd, F_GETFD) == -1 && errno == EBADF))
 
 /*
@@ -62,4 +58,6 @@ void fcntl_unlock_file(int lockfd);
  */
 int lvm_fclose(FILE *fp, const char *filename);
 
+int does_file_refer_to_fd(const char *filename, int fd);
+
 #endif


