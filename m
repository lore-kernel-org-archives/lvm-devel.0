From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 25 Jun 2007 09:02:38 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in dae ...
Message-ID: <20070625090238.10127.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-06-25 09:02:37

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in clvmd-openais.c 

Log message:
	Use cpg_local_get() rather then Clm to get the local nodeid.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.639&r2=1.640
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/06/19 10:51:51	1.639
+++ LVM2/WHATS_NEW	2007/06/25 09:02:37	1.640
@@ -4,6 +4,7 @@
   Add vg_status function and clean up vg->status in tools directory.
   Add --ignoremonitoring to disable all dmeventd interaction.
   Remove get_ prefix from get_pv_* functions.
+  clvmd-openais now uses cpg_local_get() to get nodeid, rather than Clm.
 
 Version 2.02.26 - 15th June 2007
 ================================
--- LVM2/daemons/clvmd/Makefile.in	2007/06/14 10:16:34	1.19
+++ LVM2/daemons/clvmd/Makefile.in	2007/06/25 09:02:37	1.20
@@ -59,7 +59,7 @@
 
 ifeq ("$(OPENAIS)", "yes")
 	SOURCES += clvmd-openais.c
-	LMLIBS += -lSaLck -lSaClm -lcpg
+	LMLIBS += -lSaLck -lcpg
 	DEFS += -DUSE_OPENAIS
 endif
 
--- LVM2/daemons/clvmd/clvmd-openais.c	2007/05/21 10:52:01	1.1
+++ LVM2/daemons/clvmd/clvmd-openais.c	2007/06/25 09:02:37	1.2
@@ -98,9 +98,6 @@
         .saLckResourceUnlockCallback = lck_unlock_callback
 };
 
-/* We only call Clm to get our node id */
-SaClmCallbacksT clm_callbacks;
-
 struct node_info
 {
 	enum {NODE_UNKNOWN, NODE_DOWN, NODE_UP, NODE_CLVMD} state;
@@ -348,7 +345,6 @@
 {
 	SaAisErrorT err;
 	SaVersionT  ver = { 'B', 1, 1 };
-	SaClmHandleT clm_handle;
 	int select_fd;
 	SaClmClusterNodeT cluster_node;
 
@@ -387,26 +383,14 @@
 		return ais_to_errno(err);
 	}
 
-	/* A brief foray into Clm to get our node id */
-	err = saClmInitialize(&clm_handle, &clm_callbacks, &ver);
-	if (err != SA_AIS_OK) {
-		syslog(LOG_ERR, "Could not initialize OpenAIS membership service %d\n", err);
-		DEBUGLOG("Could not initialize OpenAIS Membership service %d\n", err);
-		return ais_to_errno(err);
-	}
-
-	err = saClmClusterNodeGet(clm_handle,
-				  SA_CLM_LOCAL_NODE_ID,
-				  TIMEOUT,
-				  &cluster_node);
+	err = cpg_local_get(cpg_handle,
+			    &cluster_node);
 	if (err != SA_AIS_OK) {
 		cpg_finalize(cpg_handle);
 		saLckFinalize(lck_handle);
-		saClmFinalize(clm_handle);
 		syslog(LOG_ERR, "Cannot get local node id\n");
 		return ais_to_errno(err);
 	}
-	saClmFinalize(clm_handle);
 	our_nodeid = cluster_node.nodeId;
 	DEBUGLOG("Our local node id is %d\n", our_nodeid);
 
@@ -424,7 +408,7 @@
 	unlock_all();
 
 	saLckFinalize(lck_handle);
-	cpg_inalize(cpg_handle);
+	cpg_finalize(cpg_handle);
 }
 
 static void _get_our_csid(char *csid)


