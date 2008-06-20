From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 20 Jun 2008 12:46:22 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-openais.c
Message-ID: <20080620124622.27287.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-06-20 12:46:22

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-openais.c 

Log message:
	Make clvmd return immediately if other nodes are down in an openais cluster.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.907&r2=1.908
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2008/06/20 10:58:27	1.907
+++ LVM2/WHATS_NEW	2008/06/20 12:46:21	1.908
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Make clvmd return immediately if other nodes are down in an openais cluster.
   Make clvmd return immediately if other nodes are down in a gulm cluster.
   Improve/Fix read ahead 'auto' calculation for stripe_size
   Fix lvchange output for -r auto setting if auto is already set
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/04/29 08:55:20	1.6
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/06/20 12:46:21	1.7
@@ -452,6 +452,7 @@
 {
 	struct dm_hash_node *hn;
 	struct node_info *ninfo;
+	int somedown = 0;
 
 	dm_hash_iterate(hn, node_hash)
 	{
@@ -465,8 +466,10 @@
 
 		if (ninfo->state != NODE_DOWN)
 			callback(master_client, csid, ninfo->state == NODE_CLVMD);
+		if (ninfo->state != NODE_CLVMD)
+			somedown = -1;
 	}
-	return 0;
+	return somedown;
 }
 
 /* Real locking */


