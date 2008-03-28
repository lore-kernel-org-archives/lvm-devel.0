From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 28 Mar 2008 12:58:11 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20080328125811.12013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-03-28 12:58:10

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix a couple of uninitialised variables. The newfd one could cause
	some obscure hangs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.810&r2=1.811
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2008/03/26 18:03:35	1.810
+++ LVM2/WHATS_NEW	2008/03/28 12:58:08	1.811
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix uninitialised variable in clvmd that could cause odd hangs.
   Add vgmerge tests.
   Add pvseg_is_allocated() for identifying a PV segment allocated to a LV.
   Add list_move() for moving elements from one list to another.
--- LVM2/daemons/clvmd/clvmd.c	2008/03/17 09:37:47	1.44
+++ LVM2/daemons/clvmd/clvmd.c	2008/03/28 12:58:09	1.45
@@ -633,7 +633,7 @@
 				}
 
 				if (FD_ISSET(thisfd->fd, &in)) {
-					struct local_client *newfd;
+					struct local_client *newfd = NULL;
 					int ret;
 
 					/* Do callback */
@@ -1613,7 +1613,7 @@
 static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext)
 {
-	int len;
+	int len = 0;
 	int saved_errno = 0;
 	struct timespec delay;
 	struct timespec remtime;


