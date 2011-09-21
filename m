From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Sep 2011 10:42:54 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/clogd.c daem ...
Message-ID: <20110921104254.19358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-21 10:42:53

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: clogd.c functions.c 

Log message:
	Check for failing 'stat' and skip this loop iteration
	(since data in statbuf are invalid).
	
	Check whether sysconf managed to find _SC_PAGESIZE.
	
	Report at least debug warning about failing unlink
	(logging scheme here seems to be a different then in lvm).
	
	Duplicate terminal FDs and use similar code as is made in clvmd
	and cleanup warns about missing open/close tests.
	FIXME: Looks like we already have 3 instancies of the same code in lvm repo.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2125&r2=1.2126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/clogd.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2011/09/21 10:39:47	1.2125
+++ LVM2/WHATS_NEW	2011/09/21 10:42:53	1.2126
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add missing error checks for some system calls in cmirrord.
   Add missing log_error() to lvresize command when fsadm tool fails.
   Add support for DM_DEV_DIR device path into fsadm script.
   Support different PATH setting for fsadm script testing.
--- LVM2/daemons/cmirrord/clogd.c	2011/09/06 18:11:21	1.14
+++ LVM2/daemons/cmirrord/clogd.c	2011/09/21 10:42:53	1.15
@@ -134,6 +134,12 @@
 {
 	int pid;
 	int status;
+	int devnull;
+
+	if ((devnull = open("/dev/null", O_RDWR)) == -1) {
+		LOG_ERROR("Can't open /dev/null: %s", strerror(errno));
+		exit(EXIT_FAILURE);
+	}
 
 	signal(SIGTERM, &parent_exit_handler);
 
@@ -182,10 +188,15 @@
 	chdir("/");
 	umask(0);
 
-	close(0); close(1); close(2);
-	open("/dev/null", O_RDONLY); /* reopen stdin */
-	open("/dev/null", O_WRONLY); /* reopen stdout */
-	open("/dev/null", O_WRONLY); /* reopen stderr */
+	if (close(0) || close(1) || close(2)) {
+		LOG_ERROR("Failed to close terminal FDs");
+		exit(EXIT_FAILURE);
+	}
+
+	if ((dup2(devnull, 0) < 0) || /* reopen stdin */
+	    (dup2(devnull, 1) < 0) || /* reopen stdout */
+	    (dup2(devnull, 2) < 0))   /* reopen stderr */
+		exit(EXIT_FAILURE);
 
 	LOG_OPEN("cmirrord", LOG_PID, LOG_DAEMON);
 
--- LVM2/daemons/cmirrord/functions.c	2011/09/06 18:24:27	1.28
+++ LVM2/daemons/cmirrord/functions.c	2011/09/21 10:42:53	1.29
@@ -329,7 +329,10 @@
 		 */
 
 		sprintf(path_rtn, "/dev/mapper/%s", dep->d_name);
-		stat(path_rtn, &statbuf);
+		if (stat(path_rtn, &statbuf) < 0) {
+			LOG_DBG("Unable to stat %s", path_rtn);
+			continue;
+		}
 		if (S_ISBLK(statbuf.st_mode) &&
 		    (major(statbuf.st_rdev) == major) &&
 		    (minor(statbuf.st_rdev) == minor)) {
@@ -476,7 +479,12 @@
 	lc->sync_count = (log_sync == NOSYNC) ? region_count : 0;
 
 	if (disk_log) {
-		page_size = sysconf(_SC_PAGESIZE);
+		if ((page_size = sysconf(_SC_PAGESIZE)) < 0) {
+			LOG_ERROR("Unable to read pagesize: %s",
+				  strerror(errno));
+			r = errno;
+			goto fail;
+		}
 		pages = *(lc->clean_bits) / page_size;
 		pages += *(lc->clean_bits) % page_size ? 1 : 0;
 		pages += 1; /* for header */
@@ -489,7 +497,10 @@
 			goto fail;
 		}
 		if (unlink_path)
-			unlink(disk_path);
+			if (unlink(disk_path) < 0) {
+				LOG_DBG("Warning: Unable to unlink log device, %s: %s",
+					disk_path, strerror(errno));
+			}
 
 		lc->disk_fd = r;
 		lc->disk_size = pages * page_size;


