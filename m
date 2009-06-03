From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 3 Jun 2009 13:42:03 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-corosync.c
Message-ID: <20090603134203.11944.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-06-03 13:42:02

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Fix clvmd-corosync to match the new corosync API.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1139&r2=1.1140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2009/06/03 11:49:05	1.1139
+++ LVM2/WHATS_NEW	2009/06/03 13:42:02	1.1140
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix clvmd-corosync to match new corosync API.
   Fix makefile to build also shared libraries when running plain make.
   Fix rename of active snapshot with virtual origin.
   Fix convert polling to ignore LV with different UUID.
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/04/21 13:11:28	1.9
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/06/03 13:42:02	1.10
@@ -56,16 +56,16 @@
 #define LOCKSPACE_NAME "clvmd"
 
 static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len);
+				  size_t msg_len);
 static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries);
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries);
 static void _cluster_closedown(void);
 
 /* Hash list of nodes in the cluster */
@@ -206,17 +206,17 @@
 }
 
 static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len)
+				  size_t msg_len)
 {
 	int target_nodeid;
 
 	memcpy(&target_nodeid, msg, COROSYNC_CSID_LEN);
 
-	DEBUGLOG("%u got message from nodeid %d for %d. len %d\n",
+	DEBUGLOG("%u got message from nodeid %d for %d. len %zd\n",
 		 our_nodeid, nodeid, target_nodeid, msg_len-4);
 
 	if (nodeid != our_nodeid)
@@ -226,15 +226,15 @@
 }
 
 static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries)
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries)
 {
 	int i;
 	struct node_info *ninfo;
 
-	DEBUGLOG("confchg callback. %d joined, %d left, %d members\n",
+	DEBUGLOG("confchg callback. %zd joined, %zd left, %zd members\n",
 		 joined_list_entries, left_list_entries, member_list_entries);
 
 	for (i=0; i<joined_list_entries; i++) {
@@ -580,7 +580,7 @@
 {
 	confdb_handle_t handle;
 	int result;
-	int namelen = buflen;
+	size_t namelen = buflen;
 	hdb_handle_t cluster_handle;
 	confdb_callbacks_t callbacks = {
 		.confdb_key_change_notify_fn = NULL,


