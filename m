From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 11 Jul 2007 12:07:40 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-openais.c
Message-ID: <20070711120740.12673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-07-11 12:07:39

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-openais.c 

Log message:
	Tidy bits of clvmd-openais and improve an error report.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.651&r2=1.652
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/07/10 18:50:02	1.651
+++ LVM2/WHATS_NEW	2007/07/11 12:07:39	1.652
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Tidy clvmd-openais of redundant bits, and improve an error report.
   Cope with find_seg_by_le() failure in check_lv_segments().
   Call dev_iter_destroy() if _process_all_devs() is interrupted by sigint.
   Add vg_mda_count and pv_mda_count columns to reports.
--- LVM2/daemons/clvmd/clvmd-openais.c	2007/06/25 09:02:37	1.2
+++ LVM2/daemons/clvmd/clvmd-openais.c	2007/07/11 12:07:39	1.3
@@ -37,7 +37,6 @@
 
 #include <openais/saAis.h>
 #include <openais/saLck.h>
-#include <openais/saClm.h>
 #include <openais/cpg.h>
 
 #include "list.h"
@@ -346,7 +345,6 @@
 	SaAisErrorT err;
 	SaVersionT  ver = { 'B', 1, 1 };
 	int select_fd;
-	SaClmClusterNodeT cluster_node;
 
 	node_hash = dm_hash_create(100);
 	lock_hash = dm_hash_create(10);
@@ -379,19 +377,18 @@
 		cpg_finalize(cpg_handle);
 		saLckFinalize(lck_handle);
 		syslog(LOG_ERR, "Cannot join clvmd process group");
-		DEBUGLOG("Cannot join clvmd process group\n");
+		DEBUGLOG("Cannot join clvmd process group: %d\n", err);
 		return ais_to_errno(err);
 	}
 
 	err = cpg_local_get(cpg_handle,
-			    &cluster_node);
+			    &our_nodeid);
 	if (err != SA_AIS_OK) {
 		cpg_finalize(cpg_handle);
 		saLckFinalize(lck_handle);
 		syslog(LOG_ERR, "Cannot get local node id\n");
 		return ais_to_errno(err);
 	}
-	our_nodeid = cluster_node.nodeId;
 	DEBUGLOG("Our local node id is %d\n", our_nodeid);
 
 	saLckSelectionObjectGet(lck_handle, (SaSelectionObjectT *)&select_fd);


