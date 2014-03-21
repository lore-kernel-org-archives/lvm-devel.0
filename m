From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:05 +0000 (UTC)
Subject: master - cleanup: clvmd reindent read_from_local_sock
Message-ID: <20140321213205.262BA60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5740c00f3b6160147a5bb72217dae9ce5359a525
Commit:        5740c00f3b6160147a5bb72217dae9ce5359a525
Parent:        dd17286c90d732845df95f69d4e295103469f2bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 20 14:45:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:26 2014 +0100

cleanup: clvmd reindent read_from_local_sock

Shift indent of else branch to right since
error path returns in the front.
(Simplier to read)
---
 daemons/clvmd/clvmd.c |  364 ++++++++++++++++++++++++-------------------------
 1 files changed, 175 insertions(+), 189 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 53da928..3d7d072 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1221,7 +1221,12 @@ static int read_from_local_sock(struct local_client *thisfd)
 	int len;
 	int argslen;
 	int missing_len;
-	char buffer[PIPE_BUF + 1] = { 0 };
+	char buffer[PIPE_BUF + 1];
+	char csid[MAX_CSID_LEN];
+	int comms_pipe[2];
+	struct local_client *newfd;
+	struct clvm_header *inheader = (struct clvm_header *) buffer;
+	int status;
 
 	len = read(thisfd->fd, buffer, sizeof(buffer) - 1);
 	if (len == -1 && errno == EINTR)
@@ -1229,15 +1234,12 @@ static int read_from_local_sock(struct local_client *thisfd)
 
 	DEBUGLOG("Read on local socket %d, len = %d\n", thisfd->fd, len);
 
-	if (len) {
-		int rv = verify_message(buffer, len);
-		if (rv < 0) {
-			log_error("read_from_local_sock from %d len %d bad verify",
-				  thisfd->fd, len);
-			dump_message(buffer, len);
-			/* force error handling below */
-			len = 0;
-		}
+	if (len && verify_message(buffer, len) < 0) {
+		log_error("read_from_local_sock from %d len %d bad verify.",
+			  thisfd->fd, len);
+		dump_message(buffer, len);
+		/* force error handling below */
+		len = 0;
 	}
 
 	/* EOF or error on socket */
@@ -1245,203 +1247,187 @@ static int read_from_local_sock(struct local_client *thisfd)
 		thisfd->bits.localsock.cleanup_needed = 1;
 		(void) cleanup_zombie(thisfd); /* ignore errors here */
 		return 0;
-	} else {
-		int comms_pipe[2];
-		struct local_client *newfd;
-		char csid[MAX_CSID_LEN];
-		struct clvm_header *inheader;
-		int status;
-
-		buffer[len] = 0; /* Ensure \0 terminated */
-		inheader = (struct clvm_header *) buffer;
-
-		/* Fill in the client ID */
-		inheader->clientid = htonl(thisfd->fd);
-
-		/* If we are already busy then return an error */
-		if (thisfd->bits.localsock.in_progress) {
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = EBUSY
-			};
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending EBUSY reply to local user");
-			return len;
-		}
+	}
 
-		/* See if we have the whole message */
-		argslen =
-		    len - strlen(inheader->node) - sizeof(struct clvm_header);
-		missing_len = inheader->arglen - argslen;
-
-		if (missing_len < 0)
-			missing_len = 0;
-
-		/* We need@least sizeof(struct clvm_header) bytes in buffer */
-		if (len < (int)sizeof(struct clvm_header) || argslen < 0 ||
-		    missing_len > MAX_MISSING_LEN) {
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = EINVAL
-			};
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending EINVAL reply to local user");
-			return 0;
-		}
+	buffer[len] = 0; /* Ensure \0 terminated */
 
-		/* Free any old buffer space */
-		dm_free(thisfd->bits.localsock.cmd);
-
-		/* Save the message */
-		if (!(thisfd->bits.localsock.cmd = dm_malloc(len + missing_len))) {
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = ENOMEM
-			};
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending ENOMEM reply to local user");
-			return 0;
-		}
-		memcpy(thisfd->bits.localsock.cmd, buffer, len);
-		thisfd->bits.localsock.cmd_len = len + missing_len;
-		inheader = (struct clvm_header *) thisfd->bits.localsock.cmd;
-
-		/* If we don't have the full message then read the rest now */
-		if (missing_len) {
-			char *argptr =
-			    inheader->node + strlen(inheader->node) + 1;
-
-			while (missing_len > 0) {
-				DEBUGLOG("got %d bytes, need another %d (total %d)\n",
-					 argslen, missing_len, inheader->arglen);
-				len = read(thisfd->fd, argptr + argslen,
-					   missing_len);
-				if (len == -1 && errno == EINTR)
-					continue;
-				if (len > 0) {
-					missing_len -= len;
-					argslen += len;
-				} else {
-					/* EOF or error on socket */
-					DEBUGLOG("EOF on local socket\n");
-					dm_free(thisfd->bits.localsock.cmd);
-					thisfd->bits.localsock.cmd = NULL;
-					return 0;
-				}
-			}
-		}
+	/* Fill in the client ID */
+	inheader->clientid = htonl(thisfd->fd);
 
-		/* Initialise and lock the mutex so the subthread will wait after
-		   finishing the PRE routine */
-		if (!thisfd->bits.localsock.threadid) {
-			pthread_mutex_init(&thisfd->bits.localsock.mutex, NULL);
-			pthread_cond_init(&thisfd->bits.localsock.cond, NULL);
-			pthread_mutex_init(&thisfd->bits.localsock.reply_mutex, NULL);
-		}
+	/* If we are already busy then return an error */
+	if (thisfd->bits.localsock.in_progress) {
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = EBUSY
+		};
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending EBUSY reply to local user");
+		return len;
+	}
 
-		/* Only run the command if all the cluster nodes are running CLVMD */
-		if (((inheader->flags & CLVMD_FLAG_LOCAL) == 0) &&
-		    (check_all_clvmds_running(thisfd) == -1)) {
-			thisfd->bits.localsock.expected_replies = 0;
-			thisfd->bits.localsock.num_replies = 0;
-			send_local_reply(thisfd, EHOSTDOWN, thisfd->fd);
-			return len;
-		}
+	/* See if we have the whole message */
+	argslen = len - strlen(inheader->node) - sizeof(struct clvm_header);
+	missing_len = inheader->arglen - argslen;
+
+	if (missing_len < 0)
+		missing_len = 0;
+
+	/* We need@least sizeof(struct clvm_header) bytes in buffer */
+	if (len < (int)sizeof(struct clvm_header) || /* Already handled in verify_message() */
+	    argslen < 0 || missing_len > MAX_MISSING_LEN) {
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = EINVAL
+		};
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending EINVAL reply to local user");
+		return 0;
+	}
 
-		/* Check the node name for validity */
-		if (inheader->node[0] && clops->csid_from_name(csid, inheader->node)) {
-			/* Error, node is not in the cluster */
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = ENOENT
-			};
-
-			DEBUGLOG("Unknown node: '%s'\n", inheader->node);
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending ENOENT reply to local user");
-			thisfd->bits.localsock.expected_replies = 0;
-			thisfd->bits.localsock.num_replies = 0;
-			thisfd->bits.localsock.in_progress = FALSE;
-			thisfd->bits.localsock.sent_out = FALSE;
-			return len;
-		}
+	/* Free any old buffer space */
+	dm_free(thisfd->bits.localsock.cmd);
 
-		/* If we already have a subthread then just signal it to start */
-		if (thisfd->bits.localsock.threadid) {
-			pthread_mutex_lock(&thisfd->bits.localsock.mutex);
-			thisfd->bits.localsock.state = PRE_COMMAND;
-			pthread_cond_signal(&thisfd->bits.localsock.cond);
-			pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
-			return len;
-		}
+	/* Save the message */
+	if (!(thisfd->bits.localsock.cmd = dm_malloc(len + missing_len))) {
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = ENOMEM
+		};
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending ENOMEM reply to local user");
+		return 0;
+	}
+	memcpy(thisfd->bits.localsock.cmd, buffer, len);
+	thisfd->bits.localsock.cmd_len = len + missing_len;
+	inheader = (struct clvm_header *) thisfd->bits.localsock.cmd;
+
+	/* If we don't have the full message then read the rest now */
+	if (missing_len) {
+		char *argptr = inheader->node + strlen(inheader->node) + 1;
+
+		while (missing_len > 0) {
+			DEBUGLOG("got %d bytes, need another %d (total %d)\n",
+				 argslen, missing_len, inheader->arglen);
+			len = read(thisfd->fd, argptr + argslen, missing_len);
+			if (len == -1 && errno == EINTR)
+				continue;
 
-		/* Create a pipe and add the reading end to our FD list */
-		if (pipe(comms_pipe)) {
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = EBUSY
-			};
-
-			DEBUGLOG("creating pipe failed: %s\n", strerror(errno));
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending EBUSY reply to local user");
-			return len;
-		}
+			if (len <= 0) {
+				/* EOF or error on socket */
+				DEBUGLOG("EOF on local socket\n");
+				dm_free(thisfd->bits.localsock.cmd);
+				thisfd->bits.localsock.cmd = NULL;
+				return 0;
+			}
 
-		if (!(newfd = dm_malloc(sizeof(*newfd)))) {
-			struct clvm_header reply = {
-				.cmd = CLVMD_CMD_REPLY,
-				.status = ENOMEM
-			};
+			missing_len -= len;
+			argslen += len;
+		}
+	}
 
-			(void) close(comms_pipe[0]);
-			(void) close(comms_pipe[1]);
+	/*
+	 * Initialise and lock the mutex so the subthread will wait
+	 * after finishing the PRE routine
+	 */
+	if (!thisfd->bits.localsock.threadid) {
+		pthread_mutex_init(&thisfd->bits.localsock.mutex, NULL);
+		pthread_cond_init(&thisfd->bits.localsock.cond, NULL);
+		pthread_mutex_init(&thisfd->bits.localsock.reply_mutex, NULL);
+	}
 
-			send_message(&reply, sizeof(reply), our_csid,
-				     thisfd->fd,
-				     "Error sending ENOMEM reply to local user");
-			return len;
-		}
-		DEBUGLOG("creating pipe, [%d, %d]\n", comms_pipe[0],
-			 comms_pipe[1]);
+	/* Only run the command if all the cluster nodes are running CLVMD */
+	if (((inheader->flags & CLVMD_FLAG_LOCAL) == 0) &&
+	    (check_all_clvmds_running(thisfd) == -1)) {
+		thisfd->bits.localsock.expected_replies = 0;
+		thisfd->bits.localsock.num_replies = 0;
+		send_local_reply(thisfd, EHOSTDOWN, thisfd->fd);
+		return len;
+	}
 
-		if (fcntl(comms_pipe[0], F_SETFD, 1))
-			DEBUGLOG("setting CLOEXEC on pipe[0] failed: %s\n", strerror(errno));
-		if (fcntl(comms_pipe[1], F_SETFD, 1))
-			DEBUGLOG("setting CLOEXEC on pipe[1] failed: %s\n", strerror(errno));
+	/* Check the node name for validity */
+	if (inheader->node[0] && clops->csid_from_name(csid, inheader->node)) {
+		/* Error, node is not in the cluster */
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = ENOENT
+		};
+
+		DEBUGLOG("Unknown node: '%s'\n", inheader->node);
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending ENOENT reply to local user");
+		thisfd->bits.localsock.expected_replies = 0;
+		thisfd->bits.localsock.num_replies = 0;
+		thisfd->bits.localsock.in_progress = FALSE;
+		thisfd->bits.localsock.sent_out = FALSE;
+		return len;
+	}
 
-		newfd->fd = comms_pipe[0];
-		newfd->removeme = 0;
-		newfd->type = THREAD_PIPE;
-		newfd->callback = local_pipe_callback;
-		newfd->next = thisfd->next;
-		newfd->bits.pipe.client = thisfd;
-		newfd->bits.pipe.threadid = 0;
-		thisfd->next = newfd;
+	/* If we already have a subthread then just signal it to start */
+	if (thisfd->bits.localsock.threadid) {
+		pthread_mutex_lock(&thisfd->bits.localsock.mutex);
+		thisfd->bits.localsock.state = PRE_COMMAND;
+		pthread_cond_signal(&thisfd->bits.localsock.cond);
+		pthread_mutex_unlock(&thisfd->bits.localsock.mutex);
+		return len;
+	}
 
-		/* Store a cross link to the pipe */
-		thisfd->bits.localsock.pipe_client = newfd;
+	/* Create a pipe and add the reading end to our FD list */
+	if (pipe(comms_pipe)) {
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = EBUSY
+		};
+
+		DEBUGLOG("Creating pipe failed: %s\n", strerror(errno));
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending EBUSY reply to local user");
+		return len;
+	}
 
-		thisfd->bits.localsock.pipe = comms_pipe[1];
+	if (!(newfd = dm_zalloc(sizeof(*newfd)))) {
+		struct clvm_header reply = {
+			.cmd = CLVMD_CMD_REPLY,
+			.status = ENOMEM
+		};
 
-		/* Make sure the thread has a copy of it's own ID */
-		newfd->bits.pipe.threadid = thisfd->bits.localsock.threadid;
+		(void) close(comms_pipe[0]);
+		(void) close(comms_pipe[1]);
 
-		/* Run the pre routine */
-		thisfd->bits.localsock.in_progress = TRUE;
-		thisfd->bits.localsock.state = PRE_COMMAND;
-		thisfd->bits.localsock.cleanup_needed = 1;
-		DEBUGLOG("Creating pre&post thread\n");
-		status = pthread_create(&thisfd->bits.localsock.threadid,
-					&stack_attr, pre_and_post_thread, thisfd);
-		DEBUGLOG("Created pre&post thread, state = %d\n", status);
+		send_message(&reply, sizeof(reply), our_csid, thisfd->fd,
+			     "Error sending ENOMEM reply to local user");
+		return len;
 	}
 
+	DEBUGLOG("creating pipe, [%d, %d]\n", comms_pipe[0], comms_pipe[1]);
+
+	if (fcntl(comms_pipe[0], F_SETFD, 1))
+		DEBUGLOG("setting CLOEXEC on pipe[0] failed: %s\n", strerror(errno));
+	if (fcntl(comms_pipe[1], F_SETFD, 1))
+		DEBUGLOG("setting CLOEXEC on pipe[1] failed: %s\n", strerror(errno));
+
+	newfd->fd = comms_pipe[0];
+	newfd->type = THREAD_PIPE;
+	newfd->callback = local_pipe_callback;
+	newfd->bits.pipe.client = thisfd;
+	newfd->next = thisfd->next;
+	thisfd->next = newfd;
+
+	/* Store a cross link to the pipe */
+	thisfd->bits.localsock.pipe_client = newfd;
+	thisfd->bits.localsock.pipe = comms_pipe[1];
+
+	/* Make sure the thread has a copy of it's own ID */
+	newfd->bits.pipe.threadid = thisfd->bits.localsock.threadid;
+
+	/* Run the pre routine */
+	thisfd->bits.localsock.in_progress = TRUE;
+	thisfd->bits.localsock.state = PRE_COMMAND;
+	thisfd->bits.localsock.cleanup_needed = 1;
+	DEBUGLOG("Creating pre&post thread\n");
+	status = pthread_create(&thisfd->bits.localsock.threadid,
+				&stack_attr, pre_and_post_thread, thisfd);
+	DEBUGLOG("Created pre&post thread, state = %d\n", status);
+
 	return len;
 }
 


