From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Sep 2011 13:40:48 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/refresh_clvmd.c
Message-ID: <20110921134048.5227.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-21 13:40:47

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : refresh_clvmd.c 

Log message:
	Always sent the whole command header in restart/reload clvmd commands.
	(Newly added check catch this as invalid packet.)
	
	(N.B. that code is so fragile that it need full rewrite soon:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2126&r2=1.2127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2011/09/21 10:42:53	1.2126
+++ LVM2/WHATS_NEW	2011/09/21 13:40:46	1.2127
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Always send the whole clvmd packet header in refresh commands.
   Add missing error checks for some system calls in cmirrord.
   Add missing log_error() to lvresize command when fsadm tool fails.
   Add support for DM_DEV_DIR device path into fsadm script.
--- LVM2/daemons/clvmd/refresh_clvmd.c	2011/04/08 14:40:18	1.15
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2011/09/21 13:40:46	1.16
@@ -149,14 +149,20 @@
 
 /* Build the structure header and parse-out wildcard node names */
 static void _build_header(struct clvm_header *head, int cmd, const char *node,
-			  int len)
+			  unsigned int len)
 {
 	head->cmd = cmd;
 	head->status = 0;
 	head->flags = 0;
 	head->xid = 0;
 	head->clientid = 0;
-	head->arglen = len;
+	if (len)
+		/* 1 byte is used from struct clvm_header.args[1], so -> len - 1 */
+		head->arglen = len - 1;
+	else {
+		head->arglen = 0;
+		*head->args = '\0';
+	}
 
 	if (node) {
 		/*
@@ -198,12 +204,12 @@
 	if (_clvmd_sock == -1)
 		return 0;
 
-	/* 1 byte is used from struct clvm_header.args[1], so -> len - 1 */
-	_build_header(head, cmd, node, len - 1);
-	memcpy(head->node + strlen(head->node) + 1, data, len);
+	_build_header(head, cmd, node, len);
+	if (len)
+		memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
-			       strlen(head->node) + len - 1, &retbuf, no_response);
+			       strlen(head->node) + len, &retbuf, no_response);
 	if (!status || no_response)
 		goto out;
 


