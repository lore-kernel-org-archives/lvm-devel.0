From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:05:39 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/refresh_clvmd.c ...
Message-ID: <20110329210539.4659.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:05:39

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : refresh_clvmd.c 
	lib/locking    : cluster_locking.c 

Log message:
	Fix sending uninitilised bytes in cluster messages
	
	Fix 2 more functions sending cluster messages to avoid passing uninitilised bytes
	and compensate 1 extra byte attached to the message from the clvm_header.args[1]
	member variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1959&r2=1.1960
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2011/03/29 20:30:05	1.1959
+++ LVM2/WHATS_NEW	2011/03/29 21:05:39	1.1960
@@ -20,7 +20,7 @@
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
   Don't allocate unused VG mempool in _pvsegs_sub_single.
-  Remove uninitialised byte from end of local clvmd messages.
+  Do not send uninitialised bytes in local clvmd messages.
   Support --help option for clvmd and return error for unknown option.
   Use system page size and not hardcoded value in locking code check.
   Fix reading of released memory for printing segment type.
--- LVM2/daemons/clvmd/refresh_clvmd.c	2010/07/01 21:46:09	1.13
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2011/03/29 21:05:39	1.14
@@ -154,6 +154,7 @@
 	head->cmd = cmd;
 	head->status = 0;
 	head->flags = 0;
+	head->xid = 0;
 	head->clientid = 0;
 	head->arglen = len;
 
@@ -197,11 +198,12 @@
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, cmd, node, len);
+	/* 1 byte is used from struct clvm_header.args[1], so -> len - 1 */
+	_build_header(head, cmd, node, len - 1);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			       strlen(head->node) + len, &retbuf, no_response);
+			       strlen(head->node) + len - 1, &retbuf, no_response);
 	if (!status || no_response)
 		goto out;
 
--- LVM2/lib/locking/cluster_locking.c	2011/02/02 23:57:48	1.53
+++ LVM2/lib/locking/cluster_locking.c	2011/03/29 21:05:39	1.54
@@ -173,6 +173,7 @@
 	head->cmd = clvmd_cmd;
 	head->status = 0;
 	head->flags = 0;
+	head->xid = 0;
 	head->clientid = 0;
 	head->arglen = len;
 
@@ -216,11 +217,12 @@
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, clvmd_cmd, node, len);
+	/* 1 byte is used from struct clvm_header.args[1], so -> len - 1 */
+	_build_header(head, clvmd_cmd, node, len - 1);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			      strlen(head->node) + len, &retbuf);
+			      strlen(head->node) + len - 1, &retbuf);
 	if (!status)
 		goto out;
 


