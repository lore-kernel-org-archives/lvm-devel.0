From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:03 +0000 (UTC)
Subject: master - cleanup: clvmd indent change
Message-ID: <20140321213203.0E14F60F05@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd17286c90d732845df95f69d4e295103469f2bd
Commit:        dd17286c90d732845df95f69d4e295103469f2bd
Parent:        0b79979bb9dde5fd8bc2ef72431e5ce2a5439a3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 12:56:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:26 2014 +0100

cleanup: clvmd indent change

Plain indent changes.
---
 daemons/clvmd/clvmd-openais.c |    4 +-
 daemons/clvmd/clvmd.c         |  200 ++++++++++++++++++-----------------------
 daemons/clvmd/lvm-functions.c |   12 +--
 3 files changed, 94 insertions(+), 122 deletions(-)

diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index c91a238..29a323a 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -684,6 +684,6 @@ struct cluster_ops *init_openais_cluster(void)
 {
 	if (!_init_cluster())
 		return &_cluster_openais_ops;
-	else
-		return NULL;
+
+	return NULL;
 }
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index a21d53a..53da928 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -681,7 +681,7 @@ static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 	if (client_fd >= 0) {
 		if (!(newfd = dm_zalloc(sizeof(*newfd)))) {
 			if (close(client_fd))
-                                log_sys_error("close", "socket");
+				log_sys_error("close", "socket");
 			return 1;
 		}
 
@@ -843,9 +843,7 @@ static void main_loop(int cmd_timeout)
 		/* Wait on the cluster FD and all local sockets/pipes */
 		local_client_head.fd = clops->get_main_cluster_fd();
 		FD_ZERO(&in);
-		for (thisfd = &local_client_head; thisfd != NULL;
-		     thisfd = thisfd->next) {
-
+		for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
 			if (thisfd->removeme)
 				continue;
 
@@ -872,14 +870,10 @@ static void main_loop(int cmd_timeout)
 			char csid[MAX_CSID_LEN];
 			char buf[max_cluster_message];
 
-			for (thisfd = &local_client_head; thisfd != NULL;
-			     thisfd = thisfd->next) {
-
+			for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
 				if (thisfd->removeme && !cleanup_zombie(thisfd)) {
-					struct local_client *free_fd;
+					struct local_client *free_fd = thisfd;
 					lastfd->next = thisfd->next;
-					free_fd = thisfd;
-
 					DEBUGLOG("removeme set for fd %d\n", free_fd->fd);
 
 					/* Queue cleanup, this also frees the client struct */
@@ -892,13 +886,11 @@ static void main_loop(int cmd_timeout)
 					int ret;
 
 					/* Do callback */
-					ret =
-					    thisfd->callback(thisfd, buf,
-							     sizeof(buf), csid,
-							     &newfd);
+					ret = thisfd->callback(thisfd, buf, sizeof(buf),
+							       csid, &newfd);
 					/* Ignore EAGAIN */
-					if (ret < 0 && (errno == EAGAIN ||
-							errno == EINTR)) continue;
+					if (ret < 0 && (errno == EAGAIN || errno == EINTR))
+						continue;
 
 					/* Got error or EOF: Remove it from the list safely */
 					if (ret <= 0) {
@@ -930,14 +922,11 @@ static void main_loop(int cmd_timeout)
 		if (select_status == 0) {
 			time_t the_time = time(NULL);
 
-			for (thisfd = &local_client_head; thisfd != NULL;
-			     thisfd = thisfd->next) {
-				if (thisfd->type == LOCAL_SOCK
-				    && thisfd->bits.localsock.sent_out
-				    && thisfd->bits.localsock.sent_time +
-				    cmd_timeout < the_time
-				    && thisfd->bits.localsock.
-				    expected_replies !=
+			for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next) {
+				if (thisfd->type == LOCAL_SOCK &&
+				    thisfd->bits.localsock.sent_out &&
+				    (thisfd->bits.localsock.sent_time + cmd_timeout) < the_time &&
+				    thisfd->bits.localsock.expected_replies !=
 				    thisfd->bits.localsock.num_replies) {
 					/* Send timed out message + replies we already have */
 					DEBUGLOG("Request timed-out (send: %ld, now: %ld)\n",
@@ -968,52 +957,49 @@ static void main_loop(int cmd_timeout)
 static __attribute__ ((noreturn)) void wait_for_child(int c_pipe, int timeout)
 {
 	int child_status;
-	int sstat;
 	fd_set fds;
 	struct timeval tv = {timeout, 0};
 
 	FD_ZERO(&fds);
 	FD_SET(c_pipe, &fds);
 
-	sstat = select(c_pipe+1, &fds, NULL, NULL, timeout? &tv: NULL);
-	if (sstat == 0) {
+	switch (select(c_pipe+1, &fds, NULL, NULL, timeout? &tv: NULL)) {
+	case 0:
 		fprintf(stderr, "clvmd startup timed out\n");
 		exit(DFAIL_TIMEOUT);
-	}
-	if (sstat == 1) {
+	case 1:
 		if (read(c_pipe, &child_status, sizeof(child_status)) !=
 		    sizeof(child_status)) {
-
 			fprintf(stderr, "clvmd failed in initialisation\n");
 			exit(DFAIL_INIT);
 		}
-		else {
-			switch (child_status) {
-			case SUCCESS:
-				break;
-			case DFAIL_INIT:
-				fprintf(stderr, "clvmd failed in initialisation\n");
-				break;
-			case DFAIL_LOCAL_SOCK:
-				fprintf(stderr, "clvmd could not create local socket\n");
-				fprintf(stderr, "Another clvmd is probably already running\n");
-				break;
-			case DFAIL_CLUSTER_IF:
-				fprintf(stderr, "clvmd could not connect to cluster manager\n");
-				fprintf(stderr, "Consult syslog for more information\n");
-				break;
-			case DFAIL_MALLOC:
-				fprintf(stderr, "clvmd failed, not enough memory\n");
-				break;
-			default:
-				fprintf(stderr, "clvmd failed, error was %d\n", child_status);
-				break;
-			}
-			exit(child_status);
+
+		switch (child_status) {
+		case SUCCESS:
+			break;
+		case DFAIL_INIT:
+			fprintf(stderr, "clvmd failed in initialisation\n");
+			break;
+		case DFAIL_LOCAL_SOCK:
+			fprintf(stderr, "clvmd could not create local socket\n");
+			fprintf(stderr, "Another clvmd is probably already running\n");
+			break;
+		case DFAIL_CLUSTER_IF:
+			fprintf(stderr, "clvmd could not connect to cluster manager\n");
+			fprintf(stderr, "Consult syslog for more information\n");
+			break;
+		case DFAIL_MALLOC:
+			fprintf(stderr, "clvmd failed, not enough memory\n");
+			break;
+		default:
+			fprintf(stderr, "clvmd failed, error was %d\n", child_status);
+			break;
 		}
+		exit(child_status);
+	default:
+		fprintf(stderr, "clvmd startup, select failed: %s\n", strerror(errno));
+		exit(DFAIL_INIT);
 	}
-	fprintf(stderr, "clvmd startup, select failed: %s\n", strerror(errno));
-	exit(DFAIL_INIT);
 }
 
 /*
@@ -1192,7 +1178,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 		pthread_mutex_destroy(&thisfd->bits.localsock.mutex);
 
 		/* Remove the pipe client */
-		if (thisfd->bits.localsock.pipe_client != NULL) {
+		if (thisfd->bits.localsock.pipe_client) {
 			struct local_client *newfd;
 			struct local_client *lastfd = NULL;
 			struct local_client *free_fd = NULL;
@@ -1224,6 +1210,7 @@ static int cleanup_zombie(struct local_client *thisfd)
 
 	safe_close(&(thisfd->fd));
 	thisfd->bits.localsock.cleanup_needed = 0;
+
 	return 0;
 }
 
@@ -1255,7 +1242,8 @@ static int read_from_local_sock(struct local_client *thisfd)
 
 	/* EOF or error on socket */
 	if (len <= 0) {
-		cleanup_zombie(thisfd); /* we ignore errors here */
+		thisfd->bits.localsock.cleanup_needed = 1;
+		(void) cleanup_zombie(thisfd); /* ignore errors here */
 		return 0;
 	} else {
 		int comms_pipe[2];
@@ -1473,7 +1461,7 @@ int add_client(struct local_client *new_client)
 static int distribute_command(struct local_client *thisfd)
 {
 	struct clvm_header *inheader =
-	    (struct clvm_header *) thisfd->bits.localsock.cmd;
+		(struct clvm_header *) thisfd->bits.localsock.cmd;
 	int len = thisfd->bits.localsock.cmd_len;
 
 	thisfd->xid = global_xid++;
@@ -1487,7 +1475,7 @@ static int distribute_command(struct local_client *thisfd)
 		/* if node is empty then do it on the whole cluster */
 		if (inheader->node[0] == '\0') {
 			thisfd->bits.localsock.expected_replies =
-			    clops->get_num_nodes();
+				clops->get_num_nodes();
 			thisfd->bits.localsock.num_replies = 0;
 			thisfd->bits.localsock.sent_time = time(NULL);
 			thisfd->bits.localsock.in_progress = TRUE;
@@ -1505,30 +1493,28 @@ static int distribute_command(struct local_client *thisfd)
 			send_message(inheader, len, NULL, -1,
 				     "Error forwarding message to cluster");
 		} else {
-                        /* Do it on a single node */
+			/* Do it on a single node */
 			char csid[MAX_CSID_LEN];
 
-			if (clops->csid_from_name(csid, inheader->node)) {
+			if (clops->csid_from_name(csid, inheader->node))
 				/* This has already been checked so should not happen */
 				return 0;
+
+			/* OK, found a node... */
+			thisfd->bits.localsock.in_progress = TRUE;
+			thisfd->bits.localsock.expected_replies = 1;
+			thisfd->bits.localsock.num_replies = 0;
+
+			/* Are we the requested node ?? */
+			if (memcmp(csid, our_csid, max_csid_len) == 0) {
+				DEBUGLOG("Doing command on local node only\n");
+				add_to_lvmqueue(thisfd, inheader, len, NULL);
 			} else {
-			        /* OK, found a node... */
-				thisfd->bits.localsock.expected_replies = 1;
-				thisfd->bits.localsock.num_replies = 0;
-				thisfd->bits.localsock.in_progress = TRUE;
-
-				/* Are we the requested node ?? */
-				if (memcmp(csid, our_csid, max_csid_len) == 0) {
-					DEBUGLOG("Doing command on local node only\n");
-					add_to_lvmqueue(thisfd, inheader, len, NULL);
-				} else {
-					DEBUGLOG("Sending message to single node: %s\n",
-						 inheader->node);
-					inheader->xid = thisfd->xid;
-					send_message(inheader, len,
-						     csid, -1,
-						     "Error forwarding message to cluster node");
-				}
+				DEBUGLOG("Sending message to single node: %s\n",
+					 inheader->node);
+				inheader->xid = thisfd->xid;
+				send_message(inheader, len, csid, -1,
+					     "Error forwarding message to cluster node");
 			}
 		}
 	} else {
@@ -1560,14 +1546,12 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 
 	/* Check for GOAWAY and sulk */
 	if (msg->cmd == CLVMD_CMD_GOAWAY) {
-
 		DEBUGLOG("Told to go away by %s\n", nodename);
 		log_error("Told to go away by %s.", nodename);
 		exit(99);
 	}
 
-	/* Version check is internal - don't bother exposing it in
-	   clvmd-command.c */
+	/* Version check is internal - don't bother exposing it in clvmd-command.c */
 	if (msg->cmd == CLVMD_CMD_VERSION) {
 		int version_nums[3];
 		char node[256];
@@ -1576,8 +1560,7 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 
 		clops->name_from_csid(csid, node);
 		DEBUGLOG("Remote node %s is version %d.%d.%d\n",
-			 node,
-			 ntohl(version_nums[0]),
+			 node, ntohl(version_nums[0]),
 			 ntohl(version_nums[1]), ntohl(version_nums[2]));
 
 		if (ntohl(version_nums[0]) != CLVMD_MAJOR_VERSION) {
@@ -1610,9 +1593,8 @@ static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
 		/* FIXME: usage of init_test() is unprotected */
 		status = do_command(NULL, msg, msglen, &replyargs,
 				    buflen, &replylen);
-	else {
+	else
 		status = ENOMEM;
-	}
 
 	/* If it wasn't a reply, then reply */
 	if (msg->cmd != CLVMD_CMD_REPLY) {
@@ -2034,6 +2016,7 @@ static int process_work_item(struct lvm_thread_cmd *cmd)
 		process_remote_command(cmd->msg, cmd->msglen, cmd->client->fd,
 				       cmd->csid);
 	}
+
 	return 0;
 }
 
@@ -2108,9 +2091,9 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 		}
 		memcpy(cmd->msg, msg, msglen);
 	}
-	else {
+	else
 		cmd->msg = NULL;
-	}
+
 	cmd->client = client;
 	cmd->msglen = msglen;
 	cmd->xid = client->xid;
@@ -2118,9 +2101,8 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 	if (csid) {
 		memcpy(cmd->csid, csid, max_csid_len);
 		cmd->remote = 1;
-	} else {
+	} else
 		cmd->remote = 0;
-	}
 
 	DEBUGLOG("add_to_lvmqueue: cmd=%p. client=%p, msg=%p, len=%d, csid=%p, xid=%d\n",
 		 cmd, client, msg, msglen, csid, cmd->xid);
@@ -2189,8 +2171,7 @@ static int open_local_sock(void)
 	old_mask = umask(0077);
 
 	/* Open local socket */
-	local_socket = socket(PF_UNIX, SOCK_STREAM, 0);
-	if (local_socket < 0) {
+	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
 		log_error("Can't create local socket: %m");
 		goto error;
 	}
@@ -2225,15 +2206,10 @@ void process_message(struct local_client *client, char *buf, int len,
 		     const char *csid)
 {
 	char nodename[max_cluster_member_name_len];
-	struct clvm_header *inheader;
-	int rv;
-
-	inheader = (struct clvm_header *) buf;
+	struct clvm_header *inheader = (struct clvm_header *) buf;
 	ntoh_clvm(inheader);	/* Byteswap fields */
 
-	rv = verify_message(buf, len);
-	if (rv < 0) {
-		memset(nodename, 0, sizeof(nodename));
+	if (verify_message(buf, len) < 0) {
 		clops->name_from_csid(csid, nodename);
 		log_error("process_message from %s len %d bad verify.", nodename, len);
 		dump_message(buf, len);
@@ -2251,8 +2227,7 @@ static void check_all_callback(struct local_client *client, const char *csid,
 			       int node_up)
 {
 	if (!node_up)
-		add_reply_to_list(client, EHOSTDOWN, csid, "CLVMD not running",
-				  18);
+		add_reply_to_list(client, EHOSTDOWN, csid, "CLVMD not running", 18);
 }
 
 /* Check to see if all CLVMDs are running (ie one on
@@ -2269,10 +2244,11 @@ static int check_all_clvmds_running(struct local_client *client)
 static struct local_client *find_client(int clientid)
 {
 	struct local_client *thisfd;
-	for (thisfd = &local_client_head; thisfd != NULL; thisfd = thisfd->next) {
+
+	for (thisfd = &local_client_head; thisfd; thisfd = thisfd->next)
 		if (thisfd->fd == (int)ntohl(clientid))
 			return thisfd;
-	}
+
 	return NULL;
 }
 
@@ -2358,27 +2334,27 @@ static if_type_t get_cluster_type(void)
 	confdb_callbacks_t callbacks = { 0 };
 
 	result = confdb_initialize (&handle, &callbacks);
-        if (result != CS_OK)
+	if (result != CS_OK)
 		return type;
 
-        result = confdb_object_find_start(handle, OBJECT_PARENT_HANDLE);
+	result = confdb_object_find_start(handle, OBJECT_PARENT_HANDLE);
 	if (result != CS_OK)
 		goto out;
 
-        result = confdb_object_find(handle, OBJECT_PARENT_HANDLE, (void *)"cluster", strlen("cluster"), &cluster_handle);
-        if (result != CS_OK)
+	result = confdb_object_find(handle, OBJECT_PARENT_HANDLE, (void *)"cluster", strlen("cluster"), &cluster_handle);
+	if (result != CS_OK)
 		goto out;
 
-        result = confdb_object_find_start(handle, cluster_handle);
+	result = confdb_object_find_start(handle, cluster_handle);
 	if (result != CS_OK)
 		goto out;
 
-        result = confdb_object_find(handle, cluster_handle, (void *)"clvmd", strlen("clvmd"), &clvmd_handle);
-        if (result != CS_OK)
+	result = confdb_object_find(handle, cluster_handle, (void *)"clvmd", strlen("clvmd"), &clvmd_handle);
+	if (result != CS_OK)
 		goto out;
 
-        result = confdb_key_get(handle, clvmd_handle, (void *)"interface", strlen("interface"), buf, &namelen);
-        if (result != CS_OK)
+	result = confdb_key_get(handle, clvmd_handle, (void *)"interface", strlen("interface"), buf, &namelen);
+	if (result != CS_OK)
 		goto out;
 
 	if (namelen >= sizeof(buf))
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e523522..622eb79 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -268,16 +268,13 @@ static int hold_lock(char *resource, int mode, int flags)
 	}
 	if (lvi) {
 		/* Already exists - convert it */
-		status =
-		    sync_lock(resource, mode, flags, &lvi->lock_id);
+		status = sync_lock(resource, mode, flags, &lvi->lock_id);
 		saved_errno = errno;
 		if (!status)
 			lvi->lock_mode = mode;
-
-		if (status) {
+		else
 			DEBUGLOG("hold_lock. convert to %d failed: %s\n", mode,
 				 strerror(errno));
-		}
 		errno = saved_errno;
 	} else {
 		lvi = malloc(sizeof(struct lv_info));
@@ -607,9 +604,8 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 	    (command & LCK_CLUSTER_VG)) {
 		int oldmode;
 
-		DEBUGLOG
-		    ("post_lock_lv: resource '%s', cmd = %s, flags = %s\n",
-		     resource, decode_locking_cmd(command), decode_flags(lock_flags));
+		DEBUGLOG("post_lock_lv: resource '%s', cmd = %s, flags = %s\n",
+			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
 		/* If the lock state is PW then restore it to what it was */
 		oldmode = get_current_lock(resource);


