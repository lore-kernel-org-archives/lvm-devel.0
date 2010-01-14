From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Jan 2010 10:11:27 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20100114101127.27933.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-14 10:11:26

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Cleanup gcc warning: null argument where non-null required (arg.2)
	As the const declaration of execvp is a bit weird, using local
	dmeventdpath string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2009/07/13 21:26:41	1.29
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/01/14 10:11:26	1.30
@@ -398,6 +398,8 @@
 	int pid, ret = 0;
 	int status;
 	struct stat statbuf;
+	char dmeventdpath[] = DMEVENTD_PATH; /* const type for execvp */
+	char * const args[] = { dmeventdpath, NULL };
 
 	if (stat(fifos->client_path, &statbuf))
 		goto start_server;
@@ -437,7 +439,7 @@
 		log_error("Unable to fork.");
 
 	else if (!pid) {
-		execvp(DMEVENTD_PATH, NULL);
+		execvp(args[0], args);
 		_exit(EXIT_FAILURE);
 	} else {
 		if (waitpid(pid, &status, 0) < 0)


