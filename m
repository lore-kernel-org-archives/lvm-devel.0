From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 12:44:53 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20101129124453.26860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 12:44:52

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Remove dead assignment in wait_for_child
	
	'pid' is not used anywhere - remove it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/daemons/clvmd/clvmd.c	2010/11/08 19:37:41	1.83
+++ LVM2/daemons/clvmd/clvmd.c	2010/11/29 12:44:52	1.84
@@ -965,7 +965,6 @@
  */
 static void be_daemon(int timeout)
 {
-        pid_t pid;
 	int devnull = open("/dev/null", O_RDWR);
 	if (devnull == -1) {
 		perror("Can't open /dev/null");
@@ -974,7 +973,7 @@
 
 	pipe(child_pipe);
 
-	switch (pid = fork()) {
+	switch (fork()) {
 	case -1:
 		perror("clvmd: can't fork");
 		exit(2);


