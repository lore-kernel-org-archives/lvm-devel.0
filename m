From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 28 Apr 2008 08:57:12 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-openais.c
Message-ID: <20080428085712.4676.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-28 08:57:11

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-openais.c 

Log message:
	The attached patch is a try to make clvmd work correctly on openais stack.
	It does 2 things.
	
	1. The cpg_deliver_callback make a compare between target_nodeid and our_nodeid.
	It turns out openais set target_nodeid to 0 sometimes. for broadcasting ? I change the behavior so that lvm will process_remote also on target_nodeid == 0
	
	2. The joined_list passed to cpg_confchg_callback doesn't include the already exist nodes in the group, which leads to an incomplete node_hash. I simply add all other nodes in member_list to node_hash also.
	
	Thanks to Xinwei Hu for this patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.861&r2=1.862
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2008/04/24 02:22:07	1.861
+++ LVM2/WHATS_NEW	2008/04/28 08:57:11	1.862
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Fix nodes list in clvmd-openais, and allow for broadcast messages.
   Exclude VG_GLOBAL from internal concurrent VG lock counter.
   Fix vgsplit internal counting of snapshot LVs.
   Fix vgmerge snapshot_count when source VG contains snapshots.
--- LVM2/daemons/clvmd/clvmd-openais.c	2008/04/23 09:53:49	1.4
+++ LVM2/daemons/clvmd/clvmd-openais.c	2008/04/28 08:57:11	1.5
@@ -245,12 +245,13 @@
 
 	memcpy(&target_nodeid, msg, OPENAIS_CSID_LEN);
 
-	DEBUGLOG("Got message from nodeid %d for %d. len %d\n",
-		 nodeid, target_nodeid, msg_len-4);
+	DEBUGLOG("%u got message from nodeid %d for %d. len %d\n",
+		 our_nodeid, nodeid, target_nodeid, msg_len-4);
 
-	if (target_nodeid == our_nodeid)
-		process_message(cluster_client, (char *)msg+OPENAIS_CSID_LEN,
-				msg_len-OPENAIS_CSID_LEN, (char*)&nodeid);
+	if (nodeid != our_nodeid)
+		if (target_nodeid == our_nodeid || target_nodeid == 0)
+			process_message(cluster_client, (char *)msg+OPENAIS_CSID_LEN,
+					msg_len-OPENAIS_CSID_LEN, (char*)&nodeid);
 }
 
 static void cpg_confchg_callback(cpg_handle_t handle,
@@ -292,10 +293,29 @@
 			ninfo->state = NODE_DOWN;
 	}
 
+	for (i=0; i<member_list_entries; i++) {
+		if (member_list[i].nodeid == 0) continue;
+		ninfo = dm_hash_lookup_binary(node_hash,
+				(char *)&member_list[i].nodeid,
+				OPENAIS_CSID_LEN);
+		if (!ninfo) {
+			ninfo = malloc(sizeof(struct node_info));
+			if (!ninfo) {
+				break;
+			}
+			else {
+				ninfo->nodeid = member_list[i].nodeid;
+				dm_hash_insert_binary(node_hash,
+						(char *)&ninfo->nodeid,
+						OPENAIS_CSID_LEN, ninfo);
+			}
+		}
+		ninfo->state = NODE_CLVMD;
+	}
+
 	num_nodes = joined_list_entries;
 }
 
-
 static int lck_dispatch(struct local_client *client, char *buf, int len,
 			const char *csid, struct local_client **new_client)
 {


