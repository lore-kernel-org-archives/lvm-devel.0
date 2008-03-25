From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: Tue, 25 Mar 2008 10:42:41 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c
Message-ID: <20080325104200.20515.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-03-25 10:41:59

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c 

Log message:
	When reallocating the node IDs array, make it bigger rather than smaller!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.804&r2=1.805
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/WHATS_NEW	2008/03/17 09:37:47	1.804
+++ LVM2/WHATS_NEW	2008/03/25 10:41:59	1.805
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  clvmd no longer crashes if it sees nodeids over 50.
   Fix potential deadlock in clvmd thread handling.
   Refactor text format initialisation into _init_text_import.
   Escape double quotes and backslashes in external metadata and config data.
--- LVM2/daemons/clvmd/clvmd-cman.c	2007/05/02 12:22:40	1.20
+++ LVM2/daemons/clvmd/clvmd-cman.c	2008/03/25 10:41:59	1.21
@@ -241,7 +241,7 @@
 
 	if (nodeid >= max_updown_nodes) {
 	        int new_size = nodeid + 10;
-		int *new_updown = realloc(node_updown, new_size);
+		int *new_updown = realloc(node_updown, sizeof(int) * new_size);
 
 		if (new_updown) {
 			node_updown = new_updown;
@@ -326,7 +326,10 @@
 	}
 
 	if (node_updown == NULL) {
-		size_t buf_len = sizeof(int) * max(num_nodes, max_updown_nodes);
+		size_t buf_len;
+		if (num_nodes > max_updown_nodes)
+			max_updown_nodes = num_nodes;
+		buf_len = sizeof(int) * max_updown_nodes;
 		node_updown = malloc(buf_len);
 		if (node_updown)
 			memset(node_updown, 0, buf_len);


