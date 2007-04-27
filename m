From: Jim Meyering <jim@meyering.net>
Date: Fri, 27 Apr 2007 19:04:25 +0200
Subject: Avoid more warnings; general const-correctness improvements
Message-ID: <87irbhyciu.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Building with this

    ./configure --disable-nls --with-clvmd=cman && make

and the patch below (along with the others I've sent today),
there are no more warnings.

[At first, I was configuring --with-clvmd=all and made
 a few changes for gulm-related code, but then noticed
 it's "old", so quit looking at that part. ]

Parts of the patch below may be a tiny bit controversial, since they
work around the fact that tcp_remove_client and alloc_client both
modify their "char *csid" parameter, while logically they needn't
(and shouldn't) do that.  I.e., the sole alloc_client caller certainly
doesn't expect its addr.sin6_addr argument to be modified.  Before this
change, tcp_remove_client would modify its csid parameter, but restore
the original value right afterwards.  The only objection I can imagine
is that this change adds the overhead of the added memcpy calls.  IMHO,
they're worth the price to make the interfaces cleaner and avoid warnings.

	Avoid more warnings; general const-correctness improvements.
	* daemons/clvmd/clvmd-cman.c (_cluster_send_message):
	(_cluster_do_node_callback, _cluster_fd_callback, _add_up_node):
	(_csid_from_name, _name_from_csid, nodeid_from_csid): Add "const" to
	pointer parameters, where possible.
	* daemons/clvmd/clvmd-comms.h [struct cluster_ops]:
	(cluster_send_message, name_from_csid, csid_from_name, sync_lock):
	(cluster_fd_callback, cluster_do_node_callback, add_up_node):
	Add "const" to member decls.
	* daemons/clvmd/clvmd.c (local_sock_callback):
	(local_rendezvous_callback, local_pipe_callback):
	(timedout_callback, process_remote_command, add_reply_to_list):
	(process_reply, send_message, add_to_lvmqueue, process_message):
	(check_all_callback): Add "const" to pointer parameters, where possible.
	Update prototypes.
	* daemons/clvmd/clvmd.h (fd_callback_t): Make csid parameter "const".
	(process_message): Likewise.
	* daemons/clvmd/tcp-comms.c (tcp_remove_client): Make parameter "const".
	But since it was being modified, use a temporary copy and modify that
	instead.  Use a loop rather than two identical blocks of code.
	(alloc_client): Similarly, make the "csid" parameter "const",
	and modify a copy.
	(tcp_send_message): Change type of "csid" parameter from
	'unsigned char*' to 'const char *'.
	(get_ip_address, print_csid): Add "const".
	* daemons/clvmd/tcp-comms.h: Update prototypes.

Index: daemons/clvmd/clvmd-cman.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-cman.c,v
retrieving revision 1.17
diff -u -p -r1.17 clvmd-cman.c
--- daemons/clvmd/clvmd-cman.c	23 Apr 2007 14:55:28 -0000	1.17
+++ daemons/clvmd/clvmd-cman.c	27 Apr 2007 16:48:00 -0000
@@ -58,7 +58,7 @@ static cman_handle_t c_handle;

 static void count_clvmds_running(void);
 static void get_members(void);
-static int nodeid_from_csid(char *csid);
+static int nodeid_from_csid(const char *csid);
 static int name_from_nodeid(int nodeid, char *name);
 static void event_callback(cman_handle_t handle, void *private, int reason, int arg);
 static void data_callback(cman_handle_t handle, void *private,
@@ -128,7 +128,8 @@ static int _get_num_nodes()
 }

 /* send_message with the fd check removed */
-static int _cluster_send_message(void *buf, int msglen, char *csid, const char *errtext)
+static int _cluster_send_message(const void *buf, int msglen, const char *csid,
+				 const char *errtext)
 {
 	int nodeid = 0;

@@ -152,7 +153,8 @@ static void _get_our_csid(char *csid)

 /* Call a callback routine for each node is that known (down means not running a clvmd) */
 static int _cluster_do_node_callback(struct local_client *client,
-				     void (*callback) (struct local_client *, char *,
+				     void (*callback) (struct local_client *,
+						       const char *,
 						       int))
 {
 	int i;
@@ -205,7 +207,8 @@ static void event_callback(cman_handle_t
 }

 static struct local_client *cman_client;
-static int _cluster_fd_callback(struct local_client *fd, char *buf, int len, char *csid,
+static int _cluster_fd_callback(struct local_client *fd, char *buf, int len,
+				const char *csid,
 				struct local_client **new_client)
 {

@@ -228,7 +231,7 @@ static void data_callback(cman_handle_t 
 	process_message(cman_client, buf, len, (char *)&nodeid);
 }

-static void _add_up_node(char *csid)
+static void _add_up_node(const char *csid)
 {
 	/* It's up ! */
 	int nodeid = nodeid_from_csid(csid);
@@ -330,7 +333,7 @@ static void get_members()


 /* Convert a node name to a CSID */
-static int _csid_from_name(char *csid, char *name)
+static int _csid_from_name(char *csid, const char *name)
 {
 	int i;

@@ -344,7 +347,7 @@ static int _csid_from_name(char *csid, c
 }

 /* Convert a CSID to a node name */
-static int _name_from_csid(char *csid, char *name)
+static int _name_from_csid(const char *csid, char *name)
 {
 	int i;

@@ -376,7 +379,7 @@ static int name_from_nodeid(int nodeid, 
 }

 /* Convert a CSID to a node ID */
-static int nodeid_from_csid(char *csid)
+static int nodeid_from_csid(const char *csid)
 {
         int nodeid;

Index: daemons/clvmd/clvmd-comms.h
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd-comms.h,v
retrieving revision 1.6
diff -u -p -r1.6 clvmd-comms.h
--- daemons/clvmd/clvmd-comms.h	9 Oct 2006 14:11:57 -0000	1.6
+++ daemons/clvmd/clvmd-comms.h	27 Apr 2007 16:48:00 -0000
@@ -25,27 +25,31 @@ struct local_client;
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
Index: daemons/clvmd/clvmd.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd.c,v
retrieving revision 1.34
diff -u -p -r1.34 clvmd.c
--- daemons/clvmd/clvmd.c	29 Mar 2007 13:59:33 -0000	1.34
+++ daemons/clvmd/clvmd.c	27 Apr 2007 16:48:00 -0000
@@ -115,31 +115,32 @@ static void send_local_reply(struct loca
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
@@ -359,7 +360,8 @@ void clvmd_cluster_init_completed()

 /* Data on a connected socket */
 static int local_sock_callback(struct local_client *thisfd, char *buf, int len,
-			       char *csid, struct local_client **new_client)
+			       const char *csid,
+			       struct local_client **new_client)
 {
 	*new_client = NULL;
 	return read_from_local_sock(thisfd);
@@ -367,7 +369,7 @@ static int local_sock_callback(struct lo

 /* Data on a connected socket */
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
-				     int len, char *csid,
+				     int len, const char *csid,
 				     struct local_client **new_client)
 {
 	/* Someone connected to our local socket, accept it. */
@@ -408,7 +410,7 @@ static int local_rendezvous_callback(str
 }

 static int local_pipe_callback(struct local_client *thisfd, char *buf,
-			       int maxlen, char *csid,
+			       int maxlen, const char *csid,
 			       struct local_client **new_client)
 {
 	int len;
@@ -484,7 +486,7 @@ static int local_pipe_callback(struct lo
    add one with "ETIMEDOUT".
    NOTE: This won't race with real replies because they happen in the same thread.
 */
-static void timedout_callback(struct local_client *client, char *csid,
+static void timedout_callback(struct local_client *client, const char *csid,
 			      int node_up)
 {
 	if (node_up) {
@@ -1152,7 +1154,7 @@ static int distribute_command(struct loc

 /* Process a command from a remote node and return the result */
 static void process_remote_command(struct clvm_header *msg, int msglen, int fd,
-			    	   char *csid)
+			    	   const char *csid)
 {
 	char *replyargs;
 	char nodename[max_cluster_member_name_len];
@@ -1352,7 +1354,7 @@ static void process_remote_command(struc
    If we have got a full set then send them to the waiting client down the local
    socket */
 static void add_reply_to_list(struct local_client *client, int status,
-			      char *csid, const char *buf, int len)
+			      const char *csid, const char *buf, int len)
 {
 	struct node_reply *reply;

@@ -1529,7 +1531,7 @@ static int process_local_command(struct 
 	return status;
 }

-static int process_reply(struct clvm_header *msg, int msglen, char *csid)
+static int process_reply(const struct clvm_header *msg, int msglen, const char *csid)
 {
 	struct local_client *client = NULL;

@@ -1679,7 +1681,7 @@ static void send_version_message()
 }

 /* Send a message to either a local client or another server */
-static int send_message(void *buf, int msglen, char *csid, int fd,
+static int send_message(void *buf, int msglen, const char *csid, int fd,
 			const char *errtext)
 {
 	int len;
@@ -1811,7 +1813,7 @@ static __attribute__ ((noreturn)) void *

 /* Pass down some work to the LVM thread */
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
-			   int msglen, char *csid)
+			   int msglen, const char *csid)
 {
 	struct lvm_thread_cmd *cmd;

@@ -1889,7 +1891,8 @@ static int open_local_sock()
 	return local_socket;
 }

-void process_message(struct local_client *client, char *buf, int len, char *csid)
+void process_message(struct local_client *client, const char *buf, int len,
+		     const char *csid)
 {
 	struct clvm_header *inheader;

@@ -1902,7 +1905,7 @@ void process_message(struct local_client
 }


-static void check_all_callback(struct local_client *client, char *csid,
+static void check_all_callback(struct local_client *client, const char *csid,
 			       int node_up)
 {
 	if (!node_up)
Index: daemons/clvmd/clvmd.h
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/clvmd.h,v
retrieving revision 1.8
diff -u -p -r1.8 clvmd.h
--- daemons/clvmd/clvmd.h	30 Nov 2006 13:19:42 -0000	1.8
+++ daemons/clvmd/clvmd.h	27 Apr 2007 16:48:00 -0000
@@ -76,7 +76,8 @@ struct netsock_bits {
 };

 typedef int (*fd_callback_t) (struct local_client * fd, char *buf, int len,
-			      char *csid, struct local_client ** new_client);
+			      const char *csid,
+			      struct local_client ** new_client);

 /* One of these for each fd we are listening on */
 struct local_client {
@@ -112,7 +113,8 @@ extern void cmd_client_cleanup(struct lo
 extern int add_client(struct local_client *new_client);

 extern void clvmd_cluster_init_completed(void);
-extern void process_message(struct local_client *client, char *buf, int len, char *csid);
+extern void process_message(struct local_client *client, const char *buf,
+			    int len, const char *csid);
 extern void debuglog(const char *fmt, ... );

 int sync_lock(const char *resource, int mode, int flags, int *lockid);
Index: daemons/clvmd/tcp-comms.c
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/tcp-comms.c,v
retrieving revision 1.15
diff -u -p -r1.15 tcp-comms.c
--- daemons/clvmd/tcp-comms.c	9 May 2006 21:23:49 -0000	1.15
+++ daemons/clvmd/tcp-comms.c	27 Apr 2007 16:48:00 -0000
@@ -92,41 +92,37 @@ int init_comms(unsigned short port)
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

@@ -315,7 +311,7 @@ static int read_from_tcpsock(struct loca
     return status;
 }

-int gulm_connect_csid(char *csid, struct local_client **newclient)
+int gulm_connect_csid(const char *csid, struct local_client **newclient)
 {
     int fd;
     struct sockaddr_in6 addr;
@@ -366,7 +362,7 @@ int gulm_connect_csid(char *csid, struct
 }

 /* Send a message to a known CSID */
-static int tcp_send_message(void *buf, int msglen, unsigned char *csid, const char *errtext)
+static int tcp_send_message(void *buf, int msglen, const char *csid, const char *errtext)
 {
     int status;
     struct local_client *client;
@@ -465,7 +461,7 @@ static void map_v4_to_v6(struct in_addr 
 }

 /* Get someone else's IP address from DNS */
-int get_ip_address(char *node, char *addr)
+int get_ip_address(const char *node, char *addr)
 {
     struct hostent *he;

@@ -493,7 +489,7 @@ int get_ip_address(char *node, char *add
     return 0;
 }

-char *print_csid(char *csid)
+char *print_csid(const char *csid)
 {
     static char buf[128];
     int *icsid = (int *)csid;
Index: daemons/clvmd/tcp-comms.h
===================================================================
RCS file: /cvs/lvm2/LVM2/daemons/clvmd/tcp-comms.h,v
retrieving revision 1.4
diff -u -p -r1.4 tcp-comms.h
--- daemons/clvmd/tcp-comms.h	22 Feb 2005 16:26:21 -0000	1.4
+++ daemons/clvmd/tcp-comms.h	27 Apr 2007 16:48:00 -0000
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


