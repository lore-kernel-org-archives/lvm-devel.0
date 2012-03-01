From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 23:20:46 -0000
Subject: LVM2/tools polldaemon.c
Message-ID: <20120301232046.29671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 23:20:46

Modified files:
	tools          : polldaemon.c 

Log message:
	Check for error from dup2
	
	Do not take correct fd as error result.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/tools/polldaemon.c	2012/02/28 14:24:58	1.48
+++ LVM2/tools/polldaemon.c	2012/03/01 23:20:45	1.49
@@ -67,9 +67,9 @@
 		_exit(ECMD_FAILED);
 	}
 
-	if (dup2(null_fd, STDIN_FILENO)  || /* reopen stdin */
-	    dup2(null_fd, STDOUT_FILENO) || /* reopen stdout */
-	    dup2(null_fd, STDERR_FILENO)) { /* reopen stderr */
+	if ((dup2(null_fd, STDIN_FILENO) < 0)  || /* reopen stdin */
+	    (dup2(null_fd, STDOUT_FILENO) < 0) || /* reopen stdout */
+	    (dup2(null_fd, STDERR_FILENO) < 0)) { /* reopen stderr */
 		log_sys_error("dup2", "redirect");
 		(void) close(null_fd);
 		_exit(ECMD_FAILED);


