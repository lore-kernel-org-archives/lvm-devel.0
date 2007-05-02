From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 2 May 2007 08:23:36 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c
Message-ID: <20070502082336.27269.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-05-02 08:23:36

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c 

Log message:
	Add some more debuglogs to clvmd startup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.613&r2=1.614
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2007/04/27 20:58:45	1.613
+++ LVM2/WHATS_NEW	2007/05/02 08:23:36	1.614
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Add some more debuglogs to clvmd startup.
 
 Version 2.02.25 - 27th April 2007
 =================================
--- LVM2/daemons/clvmd/clvmd-cman.c	2007/04/27 17:46:16	1.18
+++ LVM2/daemons/clvmd/clvmd-cman.c	2007/05/02 08:23:36	1.19
@@ -78,6 +78,7 @@
 		syslog(LOG_ERR, "Can't open cluster manager socket: %m");
 		return -1;
 	}
+	DEBUGLOG("Connected to CMAN\n");
 
 	if (cman_start_recv_data(c_handle, data_callback, CLUSTER_PORT_CLVMD)) {
 		syslog(LOG_ERR, "Can't bind cluster socket: %m");
@@ -93,6 +94,8 @@
 	get_members();
 	count_clvmds_running();
 
+	DEBUGLOG("CMAN initialisation complete\n");
+
 	/* Create a lockspace for LV & VG locks to live in */
 	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
 	if (!lockspace) {
@@ -100,7 +103,7 @@
 		return -1;
 	}
 	dlm_ls_pthread_init(lockspace);
-
+	DEBUGLOG("DLM initialisation complete\n");
 	return 0;
 }
 


