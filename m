From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 1 Apr 2009 07:51:06 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-corosync.c
Message-ID: <20090401075106.24931.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-04-01 07:51:06

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Make sure clvmd-corosync releases the lockspace when it exits.
	
	patch from Xinwei Hu

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1073&r2=1.1074
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2009/03/24 13:16:34	1.1073
+++ LVM2/WHATS_NEW	2009/04/01 07:51:05	1.1074
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Make sure clvmd-corosync releases the lockspace when it exits.
   Fix segfault for vgcfgrestore on VG with missing PVs.
   Block SIGTERM & SIGINT in clvmd subthreads.
   Detect and conditionally wipe swapspace signatures in pvcreate.
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/03/06 11:29:38	1.7
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/04/01 07:51:06	1.8
@@ -334,7 +334,7 @@
 	if (err != CS_OK) {
 		cpg_finalize(cpg_handle);
 		quorum_finalize(quorum_handle);
-		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 		syslog(LOG_ERR, "Cannot join clvmd process group");
 		DEBUGLOG("Cannot join clvmd process group: %d\n", err);
 		return cs_to_errno(err);
@@ -345,7 +345,7 @@
 	if (err != CS_OK) {
 		cpg_finalize(cpg_handle);
 		quorum_finalize(quorum_handle);
-		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 		syslog(LOG_ERR, "Cannot get local node id\n");
 		return cs_to_errno(err);
 	}
@@ -361,7 +361,7 @@
 	DEBUGLOG("cluster_closedown\n");
 	unlock_all();
 
-	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 1);
 	cpg_finalize(cpg_handle);
 	quorum_finalize(quorum_handle);
 }


