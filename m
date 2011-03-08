From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Mar 2011 22:48:51 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110308224851.24874.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-08 22:48:50

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Do not send random bytes in message
	
	Fixing few issues:
	
	struct clvm_header  contains  'char args[1]' - so adding '+ 1' here
	for message length calculation is 1 byte off.
	Message with last byte uninitialized is then passed to write function.
	Update also related arglen.
	
	Initialise xid and clintid to 0.
	
	Memory allocation is checked for NULL

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1937&r2=1.1938
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW	2011/03/08 13:27:39	1.1937
+++ LVM2/WHATS_NEW	2011/03/08 22:48:50	1.1938
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Send 1 byte shorted fully initialised local clvmd messages.
   Support --help option for clvmd and return error for unknown option.
   Use system page size and not hardcoded value in locking code check.
   Fix reading of released memory for printing segment type.
--- LVM2/daemons/clvmd/clvmd.c	2011/03/08 13:27:40	1.99
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/08 22:48:50	1.100
@@ -1749,13 +1749,18 @@
 	}
 
 	/* Add in the size of our header */
-	message_len = message_len + sizeof(struct clvm_header) + 1;
-	replybuf = malloc(message_len);
+	message_len = message_len + sizeof(struct clvm_header);
+	if (!(replybuf = malloc(message_len))) {
+		DEBUGLOG("Memory allocation fails\n");
+		return;
+	}
 
 	clientreply = (struct clvm_header *) replybuf;
 	clientreply->status = status;
 	clientreply->cmd = CLVMD_CMD_REPLY;
 	clientreply->node[0] = '\0';
+	clientreply->xid = 0;
+	clientreply->clientid = 0;
 	clientreply->flags = 0;
 
 	ptr = clientreply->args;
@@ -1790,7 +1795,7 @@
 	/* Terminate with an empty node name */
 	*ptr = '\0';
 
-	clientreply->arglen = ptr - clientreply->args + 1;
+	clientreply->arglen = ptr - clientreply->args;
 
 	/* And send it */
 	send_message(replybuf, message_len, our_csid, fd,


