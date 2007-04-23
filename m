From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 23 Apr 2007 14:55:28 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c
Message-ID: <20070423145528.30279.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-04-23 15:55:28

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c 

Log message:
	Make clvmd cope with quorum devices in RHEL5
	bz#237386

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.597&r2=1.598
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2007/04/19 22:56:16	1.597
+++ LVM2/WHATS_NEW	2007/04/23 14:55:28	1.598
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Make clvmd cope with quorum devices on RHEL5
   Add dev_read_circular.
   Add pvck command stub.
   Update lists of attribute characters in man pages.
--- LVM2/daemons/clvmd/clvmd-cman.c	2006/10/09 14:11:57	1.16
+++ LVM2/daemons/clvmd/clvmd-cman.c	2007/04/23 14:55:28	1.17
@@ -121,7 +121,7 @@
 
 	/* return number of ACTIVE nodes */
 	for (i=0; i<num_nodes; i++) {
-		if (nodes[i].cn_member)
+		if (nodes[i].cn_member && nodes[i].cn_nodeid)
 			nnodes++;
 	}
 	return nnodes;
@@ -159,7 +159,7 @@
 	int somedown = 0;
 
 	for (i = 0; i < _get_num_nodes(); i++) {
-		if (nodes[i].cn_member) {
+		if (nodes[i].cn_member && nodes[i].cn_nodeid) {
 			callback(client, (char *)&nodes[i].cn_nodeid, node_updown[nodes[i].cn_nodeid]);
 			if (!node_updown[nodes[i].cn_nodeid])
 				somedown = -1;
@@ -168,8 +168,7 @@
 	return somedown;
 }
 
-/* Process OOB message from the cluster socket,
-   this currently just means that a node has stopped listening on our port */
+/* Process OOB messages from the cluster socket */
 static void event_callback(cman_handle_t handle, void *private, int reason, int arg)
 {
 	char namebuf[MAX_CLUSTER_MEMBER_NAME_LEN];


