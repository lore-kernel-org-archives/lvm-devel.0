From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Sep 2011 14:40:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20110916144008.19274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-16 14:40:07

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Fix clvmd processing of invalid request on local socket. (rommer)
	
	Code now detects small packet and wrong arglen and reply with
	error intead of infinite loop.
	
	https://bugzilla.redhat.com/show_bug.cgi?id=738484

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2115&r2=1.2116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2011/09/16 12:10:02	1.2115
+++ LVM2/WHATS_NEW	2011/09/16 14:40:06	1.2116
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix clvmd processing of invalid request on local socket.
   Fix command line option decoding.
   Reset LV status when unlinking LV from VG.
   Fix overly strict extent-count divisibility requirements for striped mirrors.
--- LVM2/daemons/clvmd/clvmd.c	2011/08/12 02:16:46	1.108
+++ LVM2/daemons/clvmd/clvmd.c	2011/09/16 14:40:07	1.109
@@ -1061,6 +1061,7 @@
 	int missing_len;
 	char buffer[PIPE_BUF];
 
+	memset(buffer, 0, PIPE_BUF);
 	len = read(thisfd->fd, buffer, sizeof(buffer));
 	if (len == -1 && errno == EINTR)
 		return 1;
@@ -1169,9 +1170,6 @@
 			return len;
 		}
 
-		/* Free any old buffer space */
-		free(thisfd->bits.localsock.cmd);
-
 		/* See if we have the whole message */
 		argslen =
 		    len - strlen(inheader->node) - sizeof(struct clvm_header);
@@ -1180,6 +1178,22 @@
 		if (missing_len < 0)
 			missing_len = 0;
 
+		/* We need@least sizeof(struct clvm_header) bytes in buffer */
+		if (len < sizeof(struct clvm_header) || argslen < 0) {
+			struct clvm_header reply;
+			reply.cmd = CLVMD_CMD_REPLY;
+			reply.status = EINVAL;
+			reply.arglen = 0;
+			reply.flags = 0;
+			send_message(&reply, sizeof(reply), our_csid,
+				     thisfd->fd,
+				     "Error sending EINVAL reply to local user");
+			return 0;
+		}
+
+		/* Free any old buffer space */
+		free(thisfd->bits.localsock.cmd);
+
 		/* Save the message */
 		thisfd->bits.localsock.cmd = malloc(len + missing_len);
 
@@ -1203,15 +1217,23 @@
 			char *argptr =
 			    inheader->node + strlen(inheader->node) + 1;
 
-			while (missing_len > 0 && len >= 0) {
+			while (missing_len > 0) {
 				DEBUGLOG
 				    ("got %d bytes, need another %d (total %d)\n",
 				     argslen, missing_len, inheader->arglen);
 				len = read(thisfd->fd, argptr + argslen,
 					   missing_len);
-				if (len >= 0) {
+				if (len == -1 && errno == EINTR)
+					continue;
+				if (len > 0) {
 					missing_len -= len;
 					argslen += len;
+				} else {
+					/* EOF or error on socket */
+					DEBUGLOG("EOF on local socket\n");
+					free(thisfd->bits.localsock.cmd);
+					thisfd->bits.localsock.cmd = NULL;
+					return 0;
 				}
 			}
 		}


