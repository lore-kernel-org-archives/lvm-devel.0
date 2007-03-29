From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 29 Mar 2007 13:59:34 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20070329135934.24669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-03-29 14:59:33

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Add some extra error checking & robustness.
	Thanks to the Crosswalk engineering team:
	Leonard Maiorani
	Henry Harris
	Scott Cannata

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.593&r2=1.594
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2007/03/27 13:35:33	1.593
+++ LVM2/WHATS_NEW	2007/03/29 13:59:32	1.594
@@ -5,6 +5,7 @@
   Fix creation and conversion of mirrors with tags.
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
+  Add extra internal error checking to clvmd
 
 Version 2.02.24 - 19th March 2007
 =================================
--- LVM2/daemons/clvmd/clvmd.c	2006/12/11 13:48:41	1.33
+++ LVM2/daemons/clvmd/clvmd.c	2007/03/29 13:59:33	1.34
@@ -56,6 +56,8 @@
 #define FALSE 0
 #endif
 
+#define MAX_RETRIES 4
+
 /* The maximum size of a message that will fit into a packet. Anything bigger
    than this is sent via the system LV */
 #define MAX_INLINE_MESSAGE (max_cluster_message-sizeof(struct clvm_header))
@@ -325,7 +327,7 @@
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
 	DEBUGLOG("starting LVM thread\n");
-	pthread_create(&lvm_thread, NULL, lvm_thread_fn, 
+	pthread_create(&lvm_thread, NULL, lvm_thread_fn,
 			(void *)(long)using_gulm);
 
 	/* Tell the rest of the cluster our version number */
@@ -375,6 +377,9 @@
 	socklen_t sl = sizeof(socka);
 	int client_fd = accept(thisfd->fd, (struct sockaddr *) &socka, &sl);
 
+	if (client_fd == -1 && errno == EINTR)
+		return 1;
+
 	if (client_fd >= 0) {
 		newfd = malloc(sizeof(struct local_client));
 		if (!newfd) {
@@ -412,6 +417,8 @@
 	int status = -1;	/* in error by default */
 
 	len = read(thisfd->fd, buffer, sizeof(int));
+	if (len == -1 && errno == EINTR)
+		return 1;
 
 	if (len == sizeof(int)) {
 		memcpy(&status, buffer, sizeof(int));
@@ -786,6 +793,8 @@
 	char buffer[PIPE_BUF];
 
 	len = read(thisfd->fd, buffer, sizeof(buffer));
+	if (len == -1 && errno == EINTR)
+		return 1;
 
 	DEBUGLOG("Read on local socket %d, len = %d\n", thisfd->fd, len);
 
@@ -901,8 +910,12 @@
 		    len - strlen(inheader->node) - sizeof(struct clvm_header);
 		missing_len = inheader->arglen - argslen;
 
+		if (missing_len < 0)
+			missing_len = 0;
+
 		/* Save the message */
 		thisfd->bits.localsock.cmd = malloc(len + missing_len);
+
 		if (!thisfd->bits.localsock.cmd) {
 			struct clvm_header reply;
 			reply.cmd = CLVMD_CMD_REPLY;
@@ -927,9 +940,8 @@
 				DEBUGLOG
 				    ("got %d bytes, need another %d (total %d)\n",
 				     argslen, missing_len, inheader->arglen);
-				len =
-				    read(thisfd->fd, argptr + argslen,
-					 missing_len);
+				len = read(thisfd->fd, argptr + argslen,
+					   missing_len);
 				if (len >= 0) {
 					missing_len -= len;
 					argslen += len;
@@ -1215,7 +1227,7 @@
 	/* Version check is internal - don't bother exposing it in
 	   clvmd-command.c */
 	if (msg->cmd == CLVMD_CMD_VERSION) {
-		int version_nums[3]; 
+		int version_nums[3];
 		char node[256];
 
 		memcpy(version_nums, msg->args, sizeof(version_nums));
@@ -1395,6 +1407,7 @@
 {
 	struct local_client *client = (struct local_client *) arg;
 	int status;
+	int write_status;
 	sigset_t ss;
 	int pipe_fd = client->bits.localsock.pipe;
 
@@ -1424,8 +1437,19 @@
 			client->bits.localsock.all_success = 0;
 
 		DEBUGLOG("Writing status %d down pipe %d\n", status, pipe_fd);
+
 		/* Tell the parent process we have finished this bit */
-		write(pipe_fd, &status, sizeof(int));
+		do {
+			write_status = write(pipe_fd, &status, sizeof(int));
+			if (write_status == sizeof(int))
+				break;
+			if (write_status < 0 &&
+			    (errno == EINTR || errno == EAGAIN))
+				continue;
+			log_error("Error sending to pipe: %m\n");
+			break;
+		} while(1);
+
 		if (status)
 			continue; /* Wait for another PRE command */
 
@@ -1446,7 +1470,16 @@
 		status = 0;
 		do_post_command(client);
 
-		write(pipe_fd, &status, sizeof(int));
+		do {
+			write_status = write(pipe_fd, &status, sizeof(int));
+			if (write_status == sizeof(int))
+				break;
+			if (write_status < 0 &&
+			    (errno == EINTR || errno == EAGAIN))
+				continue;
+			log_error("Error sending to pipe: %m\n");
+			break;
+		} while(1);
 
 		DEBUGLOG("Waiting for next pre command\n");
 
@@ -1650,6 +1683,11 @@
 			const char *errtext)
 {
 	int len;
+	int saved_errno = 0;
+	struct timespec delay;
+	struct timespec remtime;
+
+	int retry_cnt = 0;
 
 	/* Send remote messages down the cluster socket */
 	if (csid == NULL || !ISLOCAL_CSID(csid)) {
@@ -1660,14 +1698,38 @@
 
 		/* Make sure it all goes */
 		do {
+			if (retry_cnt > MAX_RETRIES)
+			{
+				errno = saved_errno;
+				log_error(errtext);
+				errno = saved_errno;
+				break;
+			}
+
 			len = write(fd, buf + ptr, msglen - ptr);
 
 			if (len <= 0) {
+				if (errno == EINTR)
+					continue;
+				if (errno == EAGAIN ||
+				    errno == EIO ||
+				    errno == ENOSPC) {
+					saved_errno = errno;
+					retry_cnt++;
+
+					delay.tv_sec = 0;
+					delay.tv_nsec = 100000;
+					remtime.tv_sec = 0;
+					remtime.tv_nsec = 0;
+					(void) nanosleep (&delay, &remtime);
+
+					continue;
+				}
 				log_error(errtext);
 				break;
 			}
 			ptr += len;
-		} while (len < msglen);
+		} while (ptr < msglen);
 	}
 	return len;
 }


