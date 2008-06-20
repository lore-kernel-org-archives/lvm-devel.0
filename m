From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 20 Jun 2008 10:58:28 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-gulm.c
Message-ID: <20080620105828.8589.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-06-20 10:58:28

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-gulm.c 

Log message:
	Make clvmd return immediately if other nodes are down in a gulm cluster.
	bz#447799

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.906&r2=1.907
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/WHATS_NEW	2008/06/18 11:32:14	1.906
+++ LVM2/WHATS_NEW	2008/06/20 10:58:27	1.907
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Make clvmd return immediately if other nodes are down in a gulm cluster.
   Improve/Fix read ahead 'auto' calculation for stripe_size
   Fix lvchange output for -r auto setting if auto is already set
   Add testcase for read ahead
--- LVM2/daemons/clvmd/clvmd-gulm.c	2007/07/24 15:35:11	1.22
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2008/06/20 10:58:28	1.23
@@ -665,6 +665,7 @@
 {
     struct dm_hash_node *hn;
     struct node_info *ninfo;
+    int somedown = 0;
 
     dm_hash_iterate(hn, node_hash)
     {
@@ -686,12 +687,14 @@
 	    client = dm_hash_lookup_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
 
 	}
+	DEBUGLOG("down_callback2. node %s, state = %d\n", ninfo->name, ninfo->state);
 	if (ninfo->state != NODE_DOWN)
 		callback(master_client, csid, ninfo->state == NODE_CLVMD);
 
-
+	if (ninfo->state != NODE_CLVMD)
+		somedown = -1;
     }
-    return 0;
+    return somedown;
 }
 
 /* Convert gulm error codes to unix errno numbers */


