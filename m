From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jul 2010 21:56:15 -0000
Subject: LVM2/libdm libdm-file.c
Message-ID: <20100727215615.11638.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-27 21:56:14

Modified files:
	libdm          : libdm-file.c 

Log message:
	Fix dm_create_lockfile error paths - incorrectly unlinked in-use lockfile.
	(Jan Friesse)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/libdm/libdm-file.c	2010/07/21 13:40:22	1.12
+++ LVM2/libdm/libdm-file.c	2010/07/27 21:56:14	1.13
@@ -104,21 +104,29 @@
 	lock.l_start = 0;
 	lock.l_whence = SEEK_SET;
 	lock.l_len = 0;
+retry_fcntl:
 	if (fcntl(fd, F_SETLK, &lock) < 0) {
-		if (errno != EACCES && errno != EAGAIN)
+		switch (errno) {
+		case EINTR:
+			goto retry_fcntl;
+			break;
+		case EACCES:
+		case EAGAIN:
 			log_error("Cannot lock lockfile [%s], error was [%s]",
 				   lockfile, strerror(errno));
-		else
+			break;
+		default:
 			log_error("process is already running");
+		}
 
-		goto fail;
+		goto fail_close;
 	}
 
 	if (ftruncate(fd, 0) < 0) {
 		log_error("Cannot truncate pidfile [%s], error was [%s]",
 			  lockfile, strerror(errno));
 
-		goto fail;
+		goto fail_close_unlink;
 	}
 
 	memset(buffer, 0, sizeof(buffer));
@@ -131,7 +139,7 @@
 		log_error("Cannot write pid to pidfile [%s], error was [%s]",
 			  lockfile, strerror(errno));
 
-		goto fail;
+		goto fail_close_unlink;
 	}
 
 	if ((write_out == 0) || (write_out < bufferlen)) {
@@ -139,30 +147,31 @@
 			  "[%" PRIsize_t "] bytes, expected [%" PRIsize_t "]\n",
 			  lockfile, write_out, bufferlen);
 
-		goto fail;
+		goto fail_close_unlink;
 	}
 
 	if ((value = fcntl(fd, F_GETFD, 0)) < 0) {
 		log_error("Cannot get close-on-exec flag from pidfile [%s], "
 			  "error was [%s]", lockfile, strerror(errno));
 
-		goto fail;
+		goto fail_close_unlink;
 	}
 	value |= FD_CLOEXEC;
 	if (fcntl(fd, F_SETFD, value) < 0) {
 		log_error("Cannot set close-on-exec flag from pidfile [%s], "
 			  "error was [%s]", lockfile, strerror(errno));
 
-		goto fail;
+		goto fail_close_unlink;
 	}
 
 	return 1;
 
-fail:
-	if (close(fd))
-		stack;
+fail_close_unlink:
 	if (unlink(lockfile))
 		stack;
+fail_close:
+	if (close(fd))
+		stack;
 
 	return 0;
 }


