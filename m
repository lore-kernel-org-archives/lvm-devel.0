From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: Mon, 13 Jul 2009 21:27:01 -0000
Subject: LVM2 daemons/dmeventd/libdevmapper-event.c lib ...
Message-ID: <20090713212642.18068.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2009-07-13 21:26:42

Modified files:
	daemons/dmeventd: libdevmapper-event.c 
	lib/misc       : lvm-exec.c 
	test           : harness.c 
	tools          : dmsetup.c 

Log message:
	Change exit() to _exit() in the child process. exit flushes stdio file buffers,
	_exit doesn't. If there were some open files, an error in exec and subsequent
	exit() would cause the buffers to be flushed twice.
	
	Example:
	
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/wait.h>
	
	int main()
	{
	printf("buu");
	if (!fork()) {
	execl("/bin/true-not-exists", "/bin/true", NULL);
	exit(1);
	}
	wait(NULL);
	return 0;
	}
	
	Signed-off-by: Mikulas Patocka <mpatocka@redhat.com
	
	---
	daemons/dmeventd/libdevmapper-event.c |    2 +-
	lib/misc/lvm-exec.c                   |    2 +-
	test/harness.c                        |    3 ++-
	tools/dmsetup.c                       |    2 +-
	4 files changed, 5 insertions(+), 4 deletions(-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-exec.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2009/06/15 12:29:41	1.28
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2009/07/13 21:26:41	1.29
@@ -438,7 +438,7 @@
 
 	else if (!pid) {
 		execvp(DMEVENTD_PATH, NULL);
-		exit(EXIT_FAILURE);
+		_exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)
 			log_error("Unable to start dmeventd: %s",
--- LVM2/lib/misc/lvm-exec.c	2009/02/28 00:54:06	1.6
+++ LVM2/lib/misc/lvm-exec.c	2009/07/13 21:26:41	1.7
@@ -68,7 +68,7 @@
 		/* FIXME Use execve directly */
 		execvp(argv[0], (char **const) argv);
 		log_sys_error("execvp", argv[0]);
-		exit(errno);
+		_exit(errno);
 	}
 
 	/* Parent */
--- LVM2/test/harness.c	2009/02/17 19:36:16	1.3
+++ LVM2/test/harness.c	2009/07/13 21:26:41	1.4
@@ -90,7 +90,8 @@
 		dup2(fds[0], 2);
 		execlp("bash", "bash", f, NULL);
 		perror("execlp");
-		exit(202);
+		fflush(stderr);
+		_exit(202);
 	} else {
 		char buf[128];
 		snprintf(buf, 128, "%s ...", f);
--- LVM2/tools/dmsetup.c	2009/06/03 20:44:49	1.116
+++ LVM2/tools/dmsetup.c	2009/07/13 21:26:42	1.117
@@ -1055,7 +1055,7 @@
 
 	if (!(pid = fork())) {
 		execvp(args[0], args);
-		exit(127);
+		_exit(127);
 	} else if (pid < (pid_t) 0)
 		return 0;
 


