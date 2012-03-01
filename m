From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Mar 2012 17:41:39 -0000
Subject: LVM2/daemons/cmirrord cluster.c
Message-ID: <20120301174139.1099.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-03-01 17:41:39

Modified files:
	daemons/cmirrord: cluster.c 

Log message:
	s/CPG_/CS_: Various CPG constants are going away, even though CPG itself stays
	
	F17 is getting rid of OpenAIS libraries (and checkpointing).  While the
	CPG stuff is staying, some if its constants are being removed.  So, we
	must adjust and use the remaining constants which the CPG constants were based on.
	
	[~]# egrep 'CPG_DISPATCH_ALL|CPG_OK' /usr/include/*/*
	corosync/corotypes.h:#define CPG_DISPATCH_ALL     CS_DISPATCH_ALL
	corosync/corotypes.h:#define CPG_OK               CS_OK

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/daemons/cmirrord/cluster.c	2012/02/29 21:15:34	1.18
+++ LVM2/daemons/cmirrord/cluster.c	2012/03/01 17:41:39	1.19
@@ -197,7 +197,7 @@
 #else
 	r = cpg_mcast_joined(entry->handle, CPG_TYPE_AGREED, &iov, 1);
 #endif
-	if (r == CPG_OK)
+	if (r == CS_OK)
 		return 0;
 
 	/* error codes found in openais/cpg.h */
@@ -940,12 +940,12 @@
 
 static int do_cluster_work(void *data __attribute__((unused)))
 {
-	int r = CPG_OK;
+	int r = CS_OK;
 	struct clog_cpg *entry, *tmp;
 
 	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
-		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
-		if (r != CPG_OK)
+		r = cpg_dispatch(entry->handle, CS_DISPATCH_ALL);
+		if (r != CS_OK)
 			LOG_ERROR("cpg_dispatch failed: %d", r);
 
 		if (entry->free_me) {
@@ -957,7 +957,7 @@
 		resend_requests(entry);
 	}
 
-	return (r == CPG_OK) ? 0 : -1;  /* FIXME: good error number? */
+	return (r == CS_OK) ? 0 : -1;  /* FIXME: good error number? */
 }
 
 static int flush_startup_list(struct clog_cpg *entry)
@@ -1585,14 +1585,14 @@
 			 SHORT_UUID(new->name.value));
 
 	r = cpg_initialize(&new->handle, &cpg_callbacks);
-	if (r != CPG_OK) {
+	if (r != CS_OK) {
 		LOG_ERROR("cpg_initialize failed:  Cannot join cluster");
 		free(new);
 		return -EPERM;
 	}
 
 	r = cpg_join(new->handle, &new->name);
-	if (r != CPG_OK) {
+	if (r != CS_OK) {
 		LOG_ERROR("cpg_join failed:  Cannot join cluster");
 		free(new);
 		return -EPERM;
@@ -1665,7 +1665,7 @@
 		abort_startup(del);
 
 	r = cpg_leave(del->handle, &del->name);
-	if (r != CPG_OK)
+	if (r != CS_OK)
 		LOG_ERROR("Error leaving CPG!");
 	return 0;
 }


