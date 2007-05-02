From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 2 May 2007 12:22:42 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20070502122242.8926.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-05-02 12:22:41

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-comms.h 
	                 clvmd.c clvmd.h tcp-comms.c tcp-comms.h 

Log message:
	Misc clvmd cleanups from Jim Meyering

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.614&r2=1.615
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2007/05/02 08:23:36	1.614
+++ LVM2/WHATS_NEW	2007/05/02 12:22:40	1.615
@@ -1,6 +1,7 @@
 Version 2.02.26 -
 =================================
   Add some more debuglogs to clvmd startup.
+  Misc clvmd cleanups
 
 Version 2.02.25 - 27th April 2007
 =================================
--- LVM2/daemons/clvmd/clvmd-cman.c	2007/05/02 08:23:36	1.19
+++ LVM2/daemons/clvmd/clvmd-cman.c	2007/05/02 12:22:40	1.20
@@ -58,7 +58,7 @@
 
 static void count_clvmds_running(void);
 static void get_members(void);
-static int nodeid_from_csid(char *csid);
+static int nodeid_from_csid(const char *csid);
 static int name_from_nodeid(int nodeid, char *name);
 static void event_callback(cman_handle_t handle, void *private, int reason, int arg);
 static void data_callback(cman_handle_t handle, void *private,
@@ -131,7 +131,8 @@
 }
 
 /* send_message with the fd check removed */
-static int _cluster_send_message(void *buf, int msglen, char *csid, const char *errtext)
+static int _cluster_send_message(const void *buf, int msglen, const char *csid,
+				 const char *errtext)
 {
 	int nodeid = 0;
 
@@ -140,7 +141,7 @@
 
 	if (cman_send_data(c_handle, buf, msglen, 0, CLUSTER_PORT_CLVMD, nodeid) <= 0)
 	{
-		log_error(errtext);
+		log_error("%s", errtext);
 	}
 	return msglen;
 }
@@ -155,7 +156,8 @@
 
 /* Call a callback routine for each node is that known (down means not running a clvmd) */
 static int _cluster_do_node_callback(struct local_client *client,
-				     void (*callback) (struct local_client *, char *,
+				     void (*callback) (struct local_client *,
+						       const char *,
 						       int))
 {
 	int i;
@@ -208,7 +210,8 @@
 }
 
 static struct local_client *cman_client;
-static int _cluster_fd_callback(struct local_client *fd, char *buf, int len, char *csid,
+static int _cluster_fd_callback(struct local_client *fd, char *buf, int len,
+				const char *csid,
 				struct local_client **new_client)
 {
 
@@ -231,7 +234,7 @@
 	process_message(cman_client, buf, len, (char *)&nodeid);
 }
 
-static void _add_up_node(char *csid)
+static void _add_up_node(const char *csid)
 {
 	/* It's up ! */
 	int nodeid = nodeid_from_csid(csid);
@@ -323,17 +326,16 @@
 	}
 
 	if (node_updown == NULL) {
-		node_updown =
-			(int *) malloc(sizeof(int) *
-				       max(num_nodes, max_updown_nodes));
-		memset(node_updown, 0,
-		       sizeof(int) * max(num_nodes, max_updown_nodes));
+		size_t buf_len = sizeof(int) * max(num_nodes, max_updown_nodes);
+		node_updown = malloc(buf_len);
+		if (node_updown)
+			memset(node_updown, 0, buf_len);
 	}
 }
 
 
 /* Convert a node name to a CSID */
-static int _csid_from_name(char *csid, char *name)
+static int _csid_from_name(char *csid, const char *name)
 {
 	int i;
 
@@ -347,7 +349,7 @@
 }
 
 /* Convert a CSID to a node name */
-static int _name_from_csid(char *csid, char *name)
+static int _name_from_csid(const char *csid, char *name)
 {
 	int i;
 
@@ -379,7 +381,7 @@
 }
 
 /* Convert a CSID to a node ID */
-static int nodeid_from_csid(char *csid)
+static int nodeid_from_csid(const char *csid)
 {
         int nodeid;
 
--- LVM2/daemons/clvmd/clvmd-command.c	2007/04/27 17:46:16	1.15
+++ LVM2/daemons/clvmd/clvmd-command.c	2007/05/02 12:22:40	1.16
@@ -95,13 +95,22 @@
 		/* Just a test message */
 	case CLVMD_CMD_TEST:
 		if (arglen > buflen) {
+			char *new_buf;
 			buflen = arglen + 200;
-			*buf = realloc(*buf, buflen);
+			new_buf = realloc(*buf, buflen);
+			if (new_buf == NULL) {
+				status = errno;
+				free (*buf);
+			}
+			*buf = new_buf;
+		}
+		if (*buf) {
+			uname(&nodeinfo);
+			*retlen = 1 + snprintf(*buf, buflen,
+					       "TEST from %s: %s v%s",
+					       nodeinfo.nodename, args,
+					       nodeinfo.release);
 		}
-		uname(&nodeinfo);
-		*retlen = 1 + snprintf(*buf, buflen, "TEST from %s: %s v%s",
-				       nodeinfo.nodename, args,
-				       nodeinfo.release);
 		break;
 
 	case CLVMD_CMD_LOCK_VG:
@@ -118,7 +127,7 @@
 		/* Replace EIO with something less scary */
 		if (status == EIO) {
 			*retlen =
-			    1 + snprintf(*buf, buflen,
+			    1 + snprintf(*buf, buflen, "%s",
 					 get_last_lvm_error());
 			return EIO;
 		}
@@ -131,7 +140,7 @@
 	case CLVMD_CMD_GET_CLUSTERNAME:
 		status = clops->get_cluster_name(*buf, buflen);
 		if (!status)
-			*retlen = strlen(*buf);
+			*retlen = strlen(*buf)+1;
 		break;
 
 	default:
@@ -141,7 +150,7 @@
 
 	/* Check the status of the command and return the error text */
 	if (status) {
-		*retlen = 1 + snprintf(*buf, buflen, strerror(status));
+		*retlen = 1 + snprintf(*buf, buflen, "%s", strerror(status));
 	}
 
 	return status;
--- LVM2/daemons/clvmd/clvmd-comms.h	2006/10/09 14:11:57	1.6
+++ LVM2/daemons/clvmd/clvmd-comms.h	2007/05/02 12:22:40	1.7
@@ -25,27 +25,31 @@
 struct cluster_ops {
 	void (*cluster_init_completed) (void);
 
-	int (*cluster_send_message) (void *buf, int msglen, char *csid,
-				const char *errtext);
-	int (*name_from_csid) (char *csid, char *name);
-	int (*csid_from_name) (char *csid, char *name);
+	int (*cluster_send_message) (const void *buf, int msglen,
+				     const char *csid,
+				     const char *errtext);
+	int (*name_from_csid) (const char *csid, char *name);
+	int (*csid_from_name) (char *csid, const char *name);
 	int (*get_num_nodes) (void);
 	int (*cluster_fd_callback) (struct local_client *fd, char *buf, int len,
-			       char *csid, struct local_client **new_client);
+				    const char *csid,
+				    struct local_client **new_client);
 	int (*get_main_cluster_fd) (void);	/* gets accept FD or cman cluster socket */
 	int (*cluster_do_node_callback) (struct local_client *client,
-				    void (*callback) (struct local_client *,
-						      char *csid, int node_up));
+					 void (*callback) (struct local_client *,
+							   const char *csid,
+							   int node_up));
 	int (*is_quorate) (void);
 
 	void (*get_our_csid) (char *csid);
-	void (*add_up_node) (char *csid);
+	void (*add_up_node) (const char *csid);
 	void (*reread_config) (void);
 	void (*cluster_closedown) (void);
 
 	int (*get_cluster_name)(char *buf, int buflen);
 
-	int (*sync_lock) (const char *resource, int mode, int flags, int *lockid);
+	int (*sync_lock) (const char *resource, int mode,
+			  int flags, int *lockid);
 	int (*sync_unlock) (const char *resource, int lockid);
 
 };
--- LVM2/daemons/clvmd/clvmd.c	2007/04/27 17:46:16	1.35
+++ LVM2/daemons/clvmd/clvmd.c	2007/05/02 12:22:40	1.36
@@ -115,31 +115,32 @@
 static void free_reply(struct local_client *client);
 static void send_version_message(void);
 static void *pre_and_post_thread(void *arg);
-static int send_message(void *buf, int msglen, char *csid, int fd,
+static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext);
 static int read_from_local_sock(struct local_client *thisfd);
 static int process_local_command(struct clvm_header *msg, int msglen,
 				 struct local_client *client,
 				 unsigned short xid);
 static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
-				   char *csid);
-static int process_reply(struct clvm_header *msg, int msglen, char *csid);
+				   const char *csid);
+static int process_reply(const struct clvm_header *msg, int msglen,
+			 const char *csid);
 static int open_local_sock(void);
 static struct local_client *find_client(int clientid);
 static void main_loop(int local_sock, int cmd_timeout);
 static void be_daemon(int start_timeout);
 static int check_all_clvmds_running(struct local_client *client);
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
-				     int len, char *csid,
+				     int len, const char *csid,
 				     struct local_client **new_client);
 static void *lvm_thread_fn(void *);
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
-			   int msglen, char *csid);
+			   int msglen, const char *csid);
 static int distribute_command(struct local_client *thisfd);
 static void hton_clvm(struct clvm_header *hdr);
 static void ntoh_clvm(struct clvm_header *hdr);
 static void add_reply_to_list(struct local_client *client, int status,
-			      char *csid, const char *buf, int len);
+			      const char *csid, const char *buf, int len);
 
 static void usage(char *prog, FILE *file)
 {
@@ -359,7 +360,8 @@
 
 /* Data on a connected socket */
 static int local_sock_callback(struct local_client *thisfd, char *buf, int len,
-			       char *csid, struct local_client **new_client)
+			       const char *csid,
+			       struct local_client **new_client)
 {
 	*new_client = NULL;
 	return read_from_local_sock(thisfd);
@@ -367,7 +369,7 @@
 
 /* Data on a connected socket */
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
-				     int len, char *csid,
+				     int len, const char *csid,
 				     struct local_client **new_client)
 {
 	/* Someone connected to our local socket, accept it. */
@@ -408,7 +410,7 @@
 }
 
 static int local_pipe_callback(struct local_client *thisfd, char *buf,
-			       int maxlen, char *csid,
+			       int maxlen, const char *csid,
 			       struct local_client **new_client)
 {
 	int len;
@@ -484,7 +486,7 @@
    add one with "ETIMEDOUT".
    NOTE: This won't race with real replies because they happen in the same thread.
 */
-static void timedout_callback(struct local_client *client, char *csid,
+static void timedout_callback(struct local_client *client, const char *csid,
 			      int node_up)
 {
 	if (node_up) {
@@ -1152,7 +1154,7 @@
 
 /* Process a command from a remote node and return the result */
 static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
-			    	   char *csid)
+			    	   const char *csid)
 {
 	char *replyargs;
 	char nodename[max_cluster_member_name_len];
@@ -1352,7 +1354,7 @@
    If we have got a full set then send them to the waiting client down the local
    socket */
 static void add_reply_to_list(struct local_client *client, int status,
-			      char *csid, const char *buf, int len)
+			      const char *csid, const char *buf, int len)
 {
 	struct node_reply *reply;
 
@@ -1529,7 +1531,7 @@
 	return status;
 }
 
-static int process_reply(struct clvm_header *msg, int msglen, char *csid)
+static int process_reply(const struct clvm_header *msg, int msglen, const char *csid)
 {
 	struct local_client *client = NULL;
 
@@ -1679,7 +1681,7 @@
 }
 
 /* Send a message to either a local client or another server */
-static int send_message(void *buf, int msglen, char *csid, int fd,
+static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext)
 {
 	int len;
@@ -1701,7 +1703,7 @@
 			if (retry_cnt > MAX_RETRIES)
 			{
 				errno = saved_errno;
-				log_error(errtext);
+				log_error("%s", errtext);
 				errno = saved_errno;
 				break;
 			}
@@ -1725,7 +1727,7 @@
 
 					continue;
 				}
-				log_error(errtext);
+				log_error("%s", errtext);
 				break;
 			}
 			ptr += len;
@@ -1811,7 +1813,7 @@
 
 /* Pass down some work to the LVM thread */
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
-			   int msglen, char *csid)
+			   int msglen, const char *csid)
 {
 	struct lvm_thread_cmd *cmd;
 
@@ -1889,7 +1891,8 @@
 	return local_socket;
 }
 
-void process_message(struct local_client *client, char *buf, int len, char *csid)
+void process_message(struct local_client *client, const char *buf, int len,
+		     const char *csid)
 {
 	struct clvm_header *inheader;
 
@@ -1902,7 +1905,7 @@
 }
 
 
-static void check_all_callback(struct local_client *client, char *csid,
+static void check_all_callback(struct local_client *client, const char *csid,
 			       int node_up)
 {
 	if (!node_up)
--- LVM2/daemons/clvmd/clvmd.h	2006/11/30 13:19:42	1.8
+++ LVM2/daemons/clvmd/clvmd.h	2007/05/02 12:22:40	1.9
@@ -76,7 +76,8 @@
 };
 
 typedef int (*fd_callback_t) (struct local_client * fd, char *buf, int len,
-			      char *csid, struct local_client ** new_client);
+			      const char *csid,
+			      struct local_client ** new_client);
 
 /* One of these for each fd we are listening on */
 struct local_client {
@@ -112,7 +113,8 @@
 extern int add_client(struct local_client *new_client);
 
 extern void clvmd_cluster_init_completed(void);
-extern void process_message(struct local_client *client, char *buf, int len, char *csid);
+extern void process_message(struct local_client *client, const char *buf,
+			    int len, const char *csid);
 extern void debuglog(const char *fmt, ... );
 
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
--- LVM2/daemons/clvmd/tcp-comms.c	2007/04/27 17:46:16	1.16
+++ LVM2/daemons/clvmd/tcp-comms.c	2007/05/02 12:22:40	1.17
@@ -92,41 +92,37 @@
     return 0;
 }
 
-void tcp_remove_client(char *csid)
- {
+void tcp_remove_client(const char *c_csid)
+{
     struct local_client *client;
+    char csid[GULM_MAX_CSID_LEN];
+    unsigned int i;
+    memcpy(csid, c_csid, sizeof csid);
     DEBUGLOG("tcp_remove_client\n");
 
     /* Don't actually close the socket here - that's the
        job of clvmd.c whch will do the job when it notices the
        other end has gone. We just need to remove the client(s) from
        the hash table so we don't try to use it for sending any more */
-    client = dm_hash_lookup_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
-    if (client)
+    for (i = 0; i < 2; i++)
     {
-	dm_hash_remove_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
-	client->removeme = 1;
-	close(client->fd);
-    }
-
-    /* Look for a mangled one too */
-    csid[0] ^= 0x80;
-
-    client = dm_hash_lookup_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
-    if (client)
-    {
-	dm_hash_remove_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
-	client->removeme = 1;
-	close(client->fd);
+	client = dm_hash_lookup_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
+	if (client)
+	{
+	    dm_hash_remove_binary(sock_hash, csid, GULM_MAX_CSID_LEN);
+	    client->removeme = 1;
+	    close(client->fd);
+	}
+	/* Look for a mangled one too, on the 2nd iteration. */
+	csid[0] ^= 0x80;
     }
-
-    /* Put it back as we found it */
-    csid[0] ^= 0x80;
 }
 
-int alloc_client(int fd, char *csid, struct local_client **new_client)
+int alloc_client(int fd, const char *c_csid, struct local_client **new_client)
 {
     struct local_client *client;
+    char csid[GULM_MAX_CSID_LEN];
+    memcpy(csid, c_csid, sizeof csid);
 
     DEBUGLOG("alloc_client %d csid = %s\n", fd, print_csid(csid));
 
@@ -315,7 +311,7 @@
     return status;
 }
 
-int gulm_connect_csid(char *csid, struct local_client **newclient)
+int gulm_connect_csid(const char *csid, struct local_client **newclient)
 {
     int fd;
     struct sockaddr_in6 addr;
@@ -366,7 +362,7 @@
 }
 
 /* Send a message to a known CSID */
-static int tcp_send_message(void *buf, int msglen, unsigned char *csid, const char *errtext)
+static int tcp_send_message(void *buf, int msglen, const char *csid, const char *errtext)
 {
     int status;
     struct local_client *client;
@@ -465,7 +461,7 @@
 }
 
 /* Get someone else's IP address from DNS */
-int get_ip_address(char *node, char *addr)
+int get_ip_address(const char *node, char *addr)
 {
     struct hostent *he;
 
@@ -493,7 +489,7 @@
     return 0;
 }
 
-char *print_csid(char *csid)
+char *print_csid(const char *csid)
 {
     static char buf[128];
     int *icsid = (int *)csid;
--- LVM2/daemons/clvmd/tcp-comms.h	2005/02/22 16:26:21	1.4
+++ LVM2/daemons/clvmd/tcp-comms.h	2007/05/02 12:22:40	1.5
@@ -5,9 +5,9 @@
 #define GULM_MAX_CLUSTER_MEMBER_NAME_LEN 128
 
 extern int init_comms(unsigned short);
-extern char *print_csid(char *);
+extern char *print_csid(const char *);
 int get_main_gulm_cluster_fd(void);
 int cluster_fd_gulm_callback(struct local_client *fd, char *buf, int len, char *csid, struct local_client **new_client);
 int gulm_cluster_send_message(void *buf, int msglen, char *csid, const char *errtext);
 void get_our_gulm_csid(char *csid);
-int gulm_connect_csid(char *csid, struct local_client **newclient);
+int gulm_connect_csid(const char *csid, struct local_client **newclient);


