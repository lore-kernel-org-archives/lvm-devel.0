From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 6 Apr 2010 15:29:31 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20100406152931.6692.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2010-04-06 15:29:31

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix a thread race in clvmd that could cause lockups on very busy systems

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1502&r2=1.1503
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2010/04/06 14:07:11	1.1502
+++ LVM2/WHATS_NEW	2010/04/06 15:29:30	1.1503
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix another thread race in clvmd.
   Refactor management of vg->pvs list.
   Fix lcov rules and generate better coverage report.
   Improve vg_validate to detect some loops in lists.
--- LVM2/daemons/clvmd/clvmd.c	2010/03/18 09:19:31	1.64
+++ LVM2/daemons/clvmd/clvmd.c	2010/04/06 15:29:30	1.65
@@ -1516,7 +1516,8 @@
 		DEBUGLOG("Waiting to do post command - state = %d\n",
 			 client->bits.localsock.state);
 
-		if (client->bits.localsock.state != POST_COMMAND) {
+		if (client->bits.localsock.state != POST_COMMAND &&
+		    !client->bits.localsock.finished) {
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}


