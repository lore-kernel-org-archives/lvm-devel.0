From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 27 Jan 2010 22:28:06 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/cluster.c
Message-ID: <20100127222806.5541.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-27 22:28:06

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: cluster.c 

Log message:
	Was using dm_list_iterate_items when I should have been using
	*_safe.  This had the effect of segfaulting the log daemon when
	converting a mirror from one log type to another.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1412&r2=1.1413
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2010/01/27 13:29:11	1.1412
+++ LVM2/WHATS_NEW	2010/01/27 22:28:05	1.1413
@@ -1,5 +1,6 @@
 Version 2.02.60 - 23rd January 2010
 ===================================
+  Fix lvconvert issue with cluster mirrors due to un'_safe' list processing
   Fix pvmove abort workaround to be cluster-aware when temporary mirror activation fails.
   Always query device by using uuid only and not name in clvmd.
   Add missing metadata reverts in pvmove error path.
--- LVM2/daemons/cmirrord/cluster.c	2010/01/20 02:43:19	1.13
+++ LVM2/daemons/cmirrord/cluster.c	2010/01/27 22:28:06	1.14
@@ -858,9 +858,9 @@
 static int do_cluster_work(void *data __attribute((unused)))
 {
 	int r = SA_AIS_OK;
-	struct clog_cpg *entry;
+	struct clog_cpg *entry, *tmp;
 
-	dm_list_iterate_items(entry, &clog_cpg_list) {
+	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
 		if (r != SA_AIS_OK)
 			LOG_ERROR("cpg_dispatch failed: %s", str_ais_error(r));


