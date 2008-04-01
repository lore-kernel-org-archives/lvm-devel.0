From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 1 Apr 2008 15:01:30 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c
Message-ID: <20080401150130.26704.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-04-01 15:01:30

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c 

Log message:
	Fix another allocation bug with clvmd and large node IDs.`

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.812&r2=1.813
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2008/03/28 19:08:23	1.812
+++ LVM2/WHATS_NEW	2008/04/01 15:01:30	1.813
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix another allocation bug with clvmd and large node IDs.
   Add find_lv_in_lv_list() and find_pv_in_pv_list().
   Fix uninitialised variable in clvmd that could cause odd hangs.
   Add vgmerge tests.
--- LVM2/daemons/clvmd/clvmd-cman.c	2008/03/25 10:41:59	1.21
+++ LVM2/daemons/clvmd/clvmd-cman.c	2008/04/01 15:01:30	1.22
@@ -297,6 +297,8 @@
 {
 	int retnodes;
 	int status;
+	int i;
+	int high_nodeid = 0;
 
 	num_nodes = cman_get_node_count(c_handle);
 	if (num_nodes == -1) {
@@ -325,10 +327,16 @@
 		exit(6);
 	}
 
+	/* Get the highest nodeid */
+	for (i=0; i<retnodes; i++) {
+		if (nodes[i].cn_nodeid > high_nodeid)
+			high_nodeid = nodes[i].cn_nodeid;
+	}
+
 	if (node_updown == NULL) {
 		size_t buf_len;
-		if (num_nodes > max_updown_nodes)
-			max_updown_nodes = num_nodes;
+		if (high_nodeid >= max_updown_nodes)
+			max_updown_nodes = high_nodeid + 1;
 		buf_len = sizeof(int) * max_updown_nodes;
 		node_updown = malloc(buf_len);
 		if (node_updown)


