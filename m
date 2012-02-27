From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:28:49 -0000
Subject: LVM2 daemons/clvmd/clvmd.c lib/misc/lvm-file.c ...
Message-ID: <20120227112849.3565.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:28:48

Modified files:
	daemons/clvmd  : clvmd.c 
	lib/misc       : lvm-file.c 
	tools          : dmsetup.c 

Log message:
	Add some log_sys_errors to close() call

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-file.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.181&r2=1.182

--- LVM2/daemons/clvmd/clvmd.c	2012/02/27 11:26:25	1.123
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/27 11:28:47	1.124
@@ -198,7 +198,8 @@
 	if (*fd >= 0) {
 		int to_close = *fd;
 		*fd = -1;
-		close(to_close);
+		if (close(to_close))
+			log_sys_error("close", ""); /* path */
 	}
 }
 
--- LVM2/lib/misc/lvm-file.c	2011/06/08 08:49:54	1.28
+++ LVM2/lib/misc/lvm-file.c	2012/02/27 11:28:47	1.29
@@ -253,7 +253,8 @@
 
 	if (fcntl(lockfd, F_SETLKW, &lock)) {
 		log_sys_error("fcntl", file);
-		close(lockfd);
+		if (close(lockfd))
+                        log_sys_error("close", file);
 		return -1;
 	}
 
--- LVM2/tools/dmsetup.c	2012/02/15 14:27:53	1.181
+++ LVM2/tools/dmsetup.c	2012/02/27 11:28:48	1.182
@@ -3240,7 +3240,8 @@
 	blksize = fsbuf.f_frsize;
 #endif
 
-	close(fd);
+	if (close(fd))
+                log_sys_error("close", file);
 
 	if (dm_snprintf(table, tlen, "%llu %llu loop %s %llu\n", 0ULL,
 			(long long unsigned)sectors, file, (long long unsigned)off) < 0)
@@ -3252,8 +3253,9 @@
 	return 1;
 
 error:
-	if (fd > -1)
-		close(fd);
+	if (fd > -1 && close(fd))
+		log_sys_error("close", file);
+
 	return 0;
 }
 


