From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Dec 2006 23:10:27 -0000
Subject: LVM2 daemons/clvmd/clvmd-command.c daemons/clv ...
Message-ID: <20061201231027.9210.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-01 23:10:26

Modified files:
	daemons/clvmd  : clvmd-command.c clvmd.c refresh_clvmd.c 
	lib/locking    : cluster_locking.c 

Log message:
	clvmd ia64 alignment fixes etc. (pjc)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/clvmd/clvmd-command.c	2006/12/01 22:48:47	1.12
+++ LVM2/daemons/clvmd/clvmd-command.c	2006/12/01 23:10:25	1.13
@@ -200,7 +200,7 @@
 	if (status)
 	    status = errno;
 	else
-	    dm_hash_insert(lock_hash, lockname, (void *)lkid);
+	    dm_hash_insert(lock_hash, lockname, (void *)(long)lkid);
     }
 
     return status;
@@ -224,7 +224,7 @@
 	switch (header->cmd) {
 	case CLVMD_CMD_TEST:
 		status = sync_lock("CLVMD_TEST", LKM_EXMODE, 0, &lockid);
-		client->bits.localsock.private = (void *) lockid;
+		client->bits.localsock.private = (void *)(long)lockid;
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
--- LVM2/daemons/clvmd/clvmd.c	2006/11/30 13:19:42	1.31
+++ LVM2/daemons/clvmd/clvmd.c	2006/12/01 23:10:25	1.32
@@ -325,7 +325,8 @@
 	/* This needs to be started after cluster initialisation
 	   as it may need to take out locks */
 	DEBUGLOG("starting LVM thread\n");
-	pthread_create(&lvm_thread, NULL, lvm_thread_fn, (void *)using_gulm);
+	pthread_create(&lvm_thread, NULL, lvm_thread_fn, 
+			(void *)(long)using_gulm);
 
 	/* Tell the rest of the cluster our version number */
 	/* CMAN can do this immediately, gulm needs to wait until
@@ -412,16 +413,17 @@
 
 	len = read(thisfd->fd, buffer, sizeof(int));
 
-	DEBUGLOG("read on PIPE %d: %d bytes: status: %d\n",
-		 thisfd->fd, len, *(int *) buffer);
-
 	if (len == sizeof(int)) {
-		status = *(int *) buffer;
+		memcpy(&status, buffer, sizeof(int));
 	}
 
+	DEBUGLOG("read on PIPE %d: %d bytes: status: %d\n",
+		 thisfd->fd, len, status);
+
 	/* EOF on pipe or an error, close it */
 	if (len <= 0) {
 		int jstat;
+		void *ret = &status;
 		close(thisfd->fd);
 
 		/* Clear out the cross-link */
@@ -431,9 +433,7 @@
 
 		/* Reap child thread */
 		if (thisfd->bits.pipe.threadid) {
-			jstat =
-			    pthread_join(thisfd->bits.pipe.threadid,
-					 (void **) &status);
+			jstat = pthread_join(thisfd->bits.pipe.threadid, &ret);
 			thisfd->bits.pipe.threadid = 0;
 			if (thisfd->bits.pipe.client != NULL)
 				thisfd->bits.pipe.client->bits.localsock.
@@ -674,7 +674,7 @@
 	close(local_sock);
 }
 
-static void wait_for_child(int c_pipe, int timeout)
+static __attribute__ ((noreturn)) void wait_for_child(int c_pipe, int timeout)
 {
 	int child_status;
 	int sstat;
@@ -1139,8 +1139,8 @@
 }
 
 /* Process a command from a remote node and return the result */
-void process_remote_command(struct clvm_header *msg, int msglen, int fd,
-			    char *csid)
+static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
+			    	   char *csid)
 {
 	char *replyargs;
 	char nodename[max_cluster_member_name_len];
@@ -1164,11 +1164,12 @@
 		    (struct clvm_header *) malloc(msg->arglen +
 						  sizeof(struct clvm_header));
 		if (newmsg) {
-			if (system_lv_read_data
-			    (nodename, (char *) newmsg,
-			     (size_t *) &msglen) == 0) {
+			ssize_t len;
+			if (system_lv_read_data(nodename, (char *) newmsg,
+			     			&len) == 0) {
 				msg = newmsg;
 				msg_malloced = 1;
+				msglen = len;
 			} else {
 				struct clvm_header head;
 				DEBUGLOG("System LV read failed\n");
@@ -1214,8 +1215,11 @@
 	/* Version check is internal - don't bother exposing it in
 	   clvmd-command.c */
 	if (msg->cmd == CLVMD_CMD_VERSION) {
-		int *version_nums = (int *) msg->args;
+		int version_nums[3]; 
 		char node[256];
+
+		memcpy(version_nums, msg->args, sizeof(version_nums));
+
 		clops->name_from_csid(csid, node);
 		DEBUGLOG("Remote node %s is version %d.%d.%d\n",
 			 node,
@@ -1387,7 +1391,7 @@
 }
 
 /* This is the thread that runs the PRE and post commands for a particular connection */
-static void *pre_and_post_thread(void *arg)
+static __attribute__ ((noreturn)) void *pre_and_post_thread(void *arg)
 {
 	struct local_client *client = (struct local_client *) arg;
 	int status;
@@ -1455,7 +1459,6 @@
 	}
 	DEBUGLOG("Subthread finished\n");
 	pthread_exit((void *) 0);
-	return 0;
 }
 
 /* Process a command on the local node and store the result */
@@ -1564,7 +1567,7 @@
 		if (thisreply->status)
 			clientreply->flags |= CLVMD_FLAG_NODEERRS;
 
-		*(int *) ptr = thisreply->status;
+		memcpy(ptr, &thisreply->status, sizeof(int));
 		ptr += sizeof(int);
 
 		if (thisreply->replymsg) {
@@ -1620,19 +1623,22 @@
 {
 	char message[sizeof(struct clvm_header) + sizeof(int) * 3];
 	struct clvm_header *msg = (struct clvm_header *) message;
-	int *version_nums = (int *) msg->args;
+	int version_nums[3];
 
 	msg->cmd = CLVMD_CMD_VERSION;
 	msg->status = 0;
 	msg->flags = 0;
 	msg->clientid = 0;
-	msg->arglen = sizeof(int) * 3;
+	msg->arglen = sizeof(version_nums);
 
 	version_nums[0] = htonl(CLVMD_MAJOR_VERSION);
 	version_nums[1] = htonl(CLVMD_MINOR_VERSION);
 	version_nums[2] = htonl(CLVMD_PATCH_VERSION);
 
+	memcpy(&msg->args, version_nums, sizeof(version_nums));
+
 	hton_clvm(msg);
+
 	clops->cluster_send_message(message, sizeof(message), NULL,
 			     "Error Sending version number");
 }
@@ -1689,11 +1695,11 @@
 /*
  * Routine that runs in the "LVM thread".
  */
-static void *lvm_thread_fn(void *arg)
+static __attribute__ ((noreturn)) void *lvm_thread_fn(void *arg)
 {
 	struct list *cmdl, *tmp;
 	sigset_t ss;
-	int using_gulm = (int)arg;
+	int using_gulm = (int)(long)arg;
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
@@ -1737,7 +1743,6 @@
 		}
 		pthread_mutex_unlock(&lvm_thread_mutex);
 	}
-	return NULL;
 }
 
 /* Pass down some work to the LVM thread */
--- LVM2/daemons/clvmd/refresh_clvmd.c	2006/10/04 08:22:16	1.1
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2006/12/01 23:10:25	1.2
@@ -183,7 +183,6 @@
 			   lvm_response_t ** response, int *num)
 {
 	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1];
-	int *outptr;
 	char *inptr;
 	char *retbuf = NULL;
 	int status;
@@ -223,17 +222,14 @@
 	 * With an extra pair of INTs on the front to sanity
 	 * check the pointer when we are given it back to free
 	 */
-	outptr = dm_malloc(sizeof(lvm_response_t) * num_responses +
+	*response = dm_malloc(sizeof(lvm_response_t) * num_responses +
 			    sizeof(int) * 2);
-	if (!outptr) {
+	if (!*response) {
 		errno = ENOMEM;
 		status = 0;
 		goto out;
 	}
 
-	*response = (lvm_response_t *) (outptr + 2);
-	outptr[0] = LVM_SIGNATURE;
-	outptr[1] = num_responses;
 	rarray = *response;
 
 	/* Unpack the response into an lvm_response_t array */
@@ -252,7 +248,7 @@
 			int j;
 			for (j = 0; j < i; j++)
 				dm_free(rarray[i].response);
-			free(outptr);
+			free(*response);
 			errno = ENOMEM;
 			status = -1;
 			goto out;
@@ -274,25 +270,15 @@
 }
 
 /* Free reply array */
-static int _cluster_free_request(lvm_response_t * response)
+static int _cluster_free_request(lvm_response_t * response, int num)
 {
-	int *ptr = (int *) response - 2;
 	int i;
-	int num;
-
-	/* Check it's ours to free */
-	if (response == NULL || *ptr != LVM_SIGNATURE) {
-		errno = EINVAL;
-		return 0;
-	}
-
-	num = ptr[1];
 
 	for (i = 0; i < num; i++) {
 		dm_free(response[i].response);
 	}
 
-	dm_free(ptr);
+	dm_free(response);
 
 	return 1;
 }
@@ -327,7 +313,7 @@
 	}
 
 	saved_errno = errno;
-	_cluster_free_request(response);
+	_cluster_free_request(response, num_responses);
 	errno = saved_errno;
 
 	return status;
--- LVM2/lib/locking/cluster_locking.c	2006/11/30 23:11:41	1.15
+++ LVM2/lib/locking/cluster_locking.c	2006/12/01 23:10:26	1.16
@@ -196,7 +196,6 @@
 			   lvm_response_t ** response, int *num)
 {
 	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute((aligned(8)));
-	int *outptr;
 	char *inptr;
 	char *retbuf = NULL;
 	int status;
@@ -236,17 +235,13 @@
 	 * With an extra pair of INTs on the front to sanity
 	 * check the pointer when we are given it back to free
 	 */
-	outptr = dm_malloc(sizeof(lvm_response_t) * num_responses +
-			    sizeof(int) * 2);
-	if (!outptr) {
+	*response = dm_malloc(sizeof(lvm_response_t) * num_responses);
+	if (!*response) {
 		errno = ENOMEM;
 		status = 0;
 		goto out;
 	}
 
-	*response = (lvm_response_t *) (outptr + 2);
-	outptr[0] = LVM_SIGNATURE;
-	outptr[1] = num_responses;
 	rarray = *response;
 
 	/* Unpack the response into an lvm_response_t array */
@@ -265,7 +260,7 @@
 			int j;
 			for (j = 0; j < i; j++)
 				dm_free(rarray[i].response);
-			free(outptr);
+			free(*response);
 			errno = ENOMEM;
 			status = -1;
 			goto out;
@@ -287,25 +282,15 @@
 }
 
 /* Free reply array */
-static int _cluster_free_request(lvm_response_t * response)
+static int _cluster_free_request(lvm_response_t * response, int num)
 {
-	int *ptr = (int *) response - 2;
 	int i;
-	int num;
-
-	/* Check it's ours to free */
-	if (response == NULL || *ptr != LVM_SIGNATURE) {
-		errno = EINVAL;
-		return 0;
-	}
-
-	num = ptr[1];
 
 	for (i = 0; i < num; i++) {
 		dm_free(response[i].response);
 	}
 
-	dm_free(ptr);
+	dm_free(response);
 
 	return 1;
 }
@@ -374,7 +359,7 @@
 	}
 
 	saved_errno = errno;
-	_cluster_free_request(response);
+	_cluster_free_request(response, num_responses);
 	errno = saved_errno;
 
 	return status;


