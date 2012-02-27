From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 09:58:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20120227095821.9896.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 09:58:19

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Drop uname call, it's not used from gulm era.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2310&r2=1.2311
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2012/02/27 09:56:27	1.2310
+++ LVM2/WHATS_NEW	2012/02/27 09:58:18	1.2311
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Drop unused call to uname() during clvmd initia.lization.
   Test allocation result in sysfs filter creation.
   Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
--- LVM2/daemons/clvmd/clvmd.c	2012/02/08 13:03:40	1.120
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/27 09:58:19	1.121
@@ -335,7 +335,6 @@
 {
 	int local_sock;
 	struct local_client *newfd, *delfd;
-	struct utsname nodeinfo;
 	struct lvm_startup_params lvm_params;
 	int opt;
 	int cmd_timeout = DEFAULT_CMD_TIMEOUT;
@@ -559,7 +558,6 @@
 	DEBUGLOG("Cluster ready, doing some more initialisation\n");
 
 	/* Save our CSID */
-	uname(&nodeinfo);
 	clops->get_our_csid(our_csid);
 
 	/* Initialise the FD list head */


