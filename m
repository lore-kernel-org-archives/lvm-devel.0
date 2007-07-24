From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Jul 2007 15:35:12 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-gulm.c da ...
Message-ID: <20070724153512.24229.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-07-24 15:35:11

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-gulm.c clvmd-gulm.h tcp-comms.c 
	                 tcp-comms.h 

Log message:
	Fix clvmd if compiled with gulm support. (2.02.26)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.669&r2=1.670
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2007/07/24 10:58:01	1.669
+++ LVM2/WHATS_NEW	2007/07/24 15:35:11	1.670
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Fix clvmd if compiled with gulm support. (2.02.26)
   Trivial fix to lvdisplay man page.
   Add vg_lock_and_read() external library function.
   Fix loading of persistent cache if cache_dir is used. (2.02.23)
--- LVM2/daemons/clvmd/clvmd-gulm.c	2007/04/27 17:46:16	1.21
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2007/07/24 15:35:11	1.22
@@ -86,12 +86,12 @@
 };
 
 /* Forward */
-static int read_from_core_sock(struct local_client *client, char *buf, int len, char *csid,
+static int read_from_core_sock(struct local_client *client, char *buf, int len, const char *csid,
 			       struct local_client **new_client);
-static int read_from_lock_sock(struct local_client *client, char *buf, int len, char *csid,
+static int read_from_lock_sock(struct local_client *client, char *buf, int len, const char *csid,
 			       struct local_client **new_client);
 static int get_all_cluster_nodes(void);
-static int _csid_from_name(char *csid, char *name);
+static int _csid_from_name(char *csid, const char *name);
 static void _cluster_closedown(void);
 
 /* In tcp-comms.c */
@@ -278,7 +278,7 @@
 }
 
 
-static int read_from_core_sock(struct local_client *client, char *buf, int len, char *csid,
+static int read_from_core_sock(struct local_client *client, char *buf, int len, const char *csid,
 			       struct local_client **new_client)
 {
     int status;
@@ -288,7 +288,7 @@
     return status<0 ? status : 1;
 }
 
-static int read_from_lock_sock(struct local_client *client, char *buf, int len, char *csid,
+static int read_from_lock_sock(struct local_client *client, char *buf, int len, const char *csid,
 			       struct local_client **new_client)
 {
     int status;
@@ -582,7 +582,7 @@
     return 1;
 }
 
-int gulm_name_from_csid(char *csid, char *name)
+int gulm_name_from_csid(const char *csid, char *name)
 {
     struct node_info *ninfo;
 
@@ -598,7 +598,7 @@
 }
 
 
-static int _csid_from_name(char *csid, char *name)
+static int _csid_from_name(char *csid, const char *name)
 {
     struct dm_hash_node *hn;
     struct node_info *ninfo;
@@ -622,7 +622,7 @@
 }
 
 /* Node is now known to be running a clvmd */
-void gulm_add_up_node(char *csid)
+void gulm_add_up_node(const char *csid)
 {
     struct node_info *ninfo;
 
@@ -661,7 +661,7 @@
 
 /* Call a callback for each node, so the caller knows whether it's up or down */
 static int _cluster_do_node_callback(struct local_client *master_client,
-				     void (*callback)(struct local_client *, char *csid, int node_up))
+				     void (*callback)(struct local_client *, const char *csid, int node_up))
 {
     struct dm_hash_node *hn;
     struct node_info *ninfo;
@@ -965,14 +965,14 @@
 	return get_main_gulm_cluster_fd();
 }
 
-static int _cluster_fd_callback(struct local_client *fd, char *buf, int len, char *csid, struct local_client **new_client)
+static int _cluster_fd_callback(struct local_client *fd, char *buf, int len, const char *csid, struct local_client **new_client)
 {
 	return cluster_fd_gulm_callback(fd, buf, len, csid, new_client);
 }
 
-static int _cluster_send_message(void *buf, int msglen, char *csid, const char *errtext)
+static int _cluster_send_message(const void *buf, int msglen, const char *csid, const char *errtext)
 {
-	return gulm_cluster_send_message(buf, msglen, csid, errtext);
+	return gulm_cluster_send_message((char *)buf, msglen, csid, errtext);
 }
 
 static int _get_cluster_name(char *buf, int buflen)
--- LVM2/daemons/clvmd/clvmd-gulm.h	2006/12/11 14:00:26	1.3
+++ LVM2/daemons/clvmd/clvmd-gulm.h	2007/07/24 15:35:11	1.4
@@ -5,9 +5,9 @@
 extern int get_next_node_csid(void **context, char *csid);
 extern void add_down_node(char *csid);
 extern int gulm_fd(void);
-extern int get_ip_address(char *node, char *addr);
-extern void tcp_remove_client(char *csid);
-extern int alloc_client(int fd, char *csid, struct local_client **new_client);
+extern int get_ip_address(const char *node, char *addr);
+extern void tcp_remove_client(const char *csid);
+extern int alloc_client(int fd, const char *csid, struct local_client **new_client);
 
-void gulm_add_up_node(char *csid);
-int gulm_name_from_csid(char *csid, char *name);
+void gulm_add_up_node(const char *csid);
+int gulm_name_from_csid(const char *csid, char *name);
--- LVM2/daemons/clvmd/tcp-comms.c	2007/05/02 12:22:40	1.17
+++ LVM2/daemons/clvmd/tcp-comms.c	2007/07/24 15:35:11	1.18
@@ -177,7 +177,7 @@
 
 
 /* Read on main comms (listen) socket, accept it */
-int cluster_fd_gulm_callback(struct local_client *fd, char *buf, int len, char *csid,
+int cluster_fd_gulm_callback(struct local_client *fd, char *buf, int len, const char *csid,
 			struct local_client **new_client)
 {
     int newfd;
@@ -390,7 +390,7 @@
 }
 
 
-int gulm_cluster_send_message(void *buf, int msglen, char *csid, const char *errtext)
+int gulm_cluster_send_message(void *buf, int msglen, const char *csid, const char *errtext)
 {
     int status=0;
 
--- LVM2/daemons/clvmd/tcp-comms.h	2007/05/02 12:22:40	1.5
+++ LVM2/daemons/clvmd/tcp-comms.h	2007/07/24 15:35:11	1.6
@@ -7,7 +7,7 @@
 extern int init_comms(unsigned short);
 extern char *print_csid(const char *);
 int get_main_gulm_cluster_fd(void);
-int cluster_fd_gulm_callback(struct local_client *fd, char *buf, int len, char *csid, struct local_client **new_client);
-int gulm_cluster_send_message(void *buf, int msglen, char *csid, const char *errtext);
+int cluster_fd_gulm_callback(struct local_client *fd, char *buf, int len, const char *csid, struct local_client **new_client);
+int gulm_cluster_send_message(void *buf, int msglen, const char *csid, const char *errtext);
 void get_our_gulm_csid(char *csid);
 int gulm_connect_csid(const char *csid, struct local_client **newclient);


