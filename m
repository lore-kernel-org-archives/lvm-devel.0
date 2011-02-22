From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Feb 2011 10:01:12 -0000
Subject: LVM2/daemons/clvmd clvmd-openais.c
Message-ID: <20110222100112.25580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-22 10:01:11

Modified files:
	daemons/clvmd  : clvmd-openais.c 

Log message:
	Remove a few size_t type warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/clvmd/clvmd-openais.c	2010/06/21 15:56:58	1.15
+++ LVM2/daemons/clvmd/clvmd-openais.c	2011/02/22 10:01:11	1.16
@@ -227,7 +227,7 @@
 
 	memcpy(&target_nodeid, msg, OPENAIS_CSID_LEN);
 
-	DEBUGLOG("%u got message from nodeid %d for %d. len %d\n",
+	DEBUGLOG("%u got message from nodeid %d for %d. len %" PRIsize_t "\n",
 		 our_nodeid, nodeid, target_nodeid, msg_len-4);
 
 	if (nodeid != our_nodeid)
@@ -245,7 +245,8 @@
 	int i;
 	struct node_info *ninfo;
 
-	DEBUGLOG("confchg callback. %d joined, %d left, %d members\n",
+	DEBUGLOG("confchg callback. %" PRIsize_t " joined, "
+		 "%" PRIsize_t " left, %" PRIsize_t " members\n",
 		 joined_list_entries, left_list_entries, member_list_entries);
 
 	for (i=0; i<joined_list_entries; i++) {


