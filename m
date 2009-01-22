From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 22 Jan 2009 10:21:13 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in dae ...
Message-ID: <20090122102113.32549.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-01-22 10:21:12

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in clvmd-comms.h clvmd.c 
Added files:
	daemons/clvmd  : clvmd-corosync.c 

Log message:
	Add a corosync/DLM cluster service to clvmd.
	
	It's not integrated in the configure system yet though.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1023&r2=1.1024
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2009/01/20 17:39:07	1.1023
+++ LVM2/WHATS_NEW	2009/01/22 10:21:12	1.1024
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add corosync/DLM cluster interface to clvmd
   Add --nameprefixes, --unquoted, --rows to pvs, vgs, lvs man pages.
   Fix fsadm failure with block size != 1K.
   Fix pvs segfault when run with orphan PV and some VG fields.
/cvs/lvm2/LVM2/daemons/clvmd/clvmd-corosync.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clvmd/clvmd-corosync.c
+++ -	2009-01-22 10:21:13.020592000 +0000
@@ -0,0 +1,591 @@
+/******************************************************************************
+*******************************************************************************
+**
+**  Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+**
+*******************************************************************************
+******************************************************************************/
+
+/* This provides the interface between clvmd and corosync/DLM as the cluster
+ * and lock manager.
+ *
+ */
+
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <configure.h>
+#include <pthread.h>
+#include <sys/types.h>
+#include <sys/utsname.h>
+#include <sys/ioctl.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/file.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <signal.h>
+#include <fcntl.h>
+#include <string.h>
+#include <stddef.h>
+#include <stdint.h>
+#include <unistd.h>
+#include <errno.h>
+#include <utmpx.h>
+#include <syslog.h>
+#include <assert.h>
+#include <libdevmapper.h>
+
+#include <corosync/corotypes.h>
+#include <corosync/cpg.h>
+#include <corosync/quorum.h>
+#include <libdlm.h>
+
+#include "locking.h"
+#include "lvm-logging.h"
+#include "clvm.h"
+#include "clvmd-comms.h"
+#include "lvm-functions.h"
+#include "clvmd.h"
+
+/* Timeout value for several corosync calls */
+#define LOCKSPACE_NAME "clvmd"
+
+static void cpg_deliver_callback (cpg_handle_t handle,
+				  struct cpg_name *groupName,
+				  uint32_t nodeid,
+				  uint32_t pid,
+				  void *msg,
+				  int msg_len);
+static void cpg_confchg_callback(cpg_handle_t handle,
+				 struct cpg_name *groupName,
+				 struct cpg_address *member_list, int member_list_entries,
+				 struct cpg_address *left_list, int left_list_entries,
+				 struct cpg_address *joined_list, int joined_list_entries);
+static void _cluster_closedown(void);
+
+/* Hash list of nodes in the cluster */
+static struct dm_hash_table *node_hash;
+
+/* Number of active nodes */
+static int num_nodes;
+static unsigned int our_nodeid;
+
+static struct local_client *cluster_client;
+
+/* Corosync handles */
+static cpg_handle_t cpg_handle;
+static quorum_handle_t quorum_handle;
+
+/* DLM Handle */
+static dlm_lshandle_t *lockspace;
+
+static struct cpg_name cpg_group_name;
+
+/* Corosync callback structs */
+cpg_callbacks_t cpg_callbacks = {
+	.cpg_deliver_fn =            cpg_deliver_callback,
+	.cpg_confchg_fn =            cpg_confchg_callback,
+};
+
+quorum_callbacks_t quorum_callbacks = {
+	.quorum_notify_fn = NULL,
+};
+
+struct node_info
+{
+	enum {NODE_UNKNOWN, NODE_DOWN, NODE_UP, NODE_CLVMD} state;
+	int nodeid;
+};
+
+
+/* Set errno to something approximating the right value and return 0 or -1 */
+static int cs_to_errno(cs_error_t err)
+{
+	switch(err)
+	{
+	case CS_OK:
+		return 0;
+        case CS_ERR_LIBRARY:
+		errno = EINVAL;
+		break;
+        case CS_ERR_VERSION:
+		errno = EINVAL;
+		break;
+        case CS_ERR_INIT:
+		errno = EINVAL;
+		break;
+        case CS_ERR_TIMEOUT:
+		errno = ETIME;
+		break;
+        case CS_ERR_TRY_AGAIN:
+		errno = EAGAIN;
+		break;
+        case CS_ERR_INVALID_PARAM:
+		errno = EINVAL;
+		break;
+        case CS_ERR_NO_MEMORY:
+		errno = ENOMEM;
+		break;
+        case CS_ERR_BAD_HANDLE:
+		errno = EINVAL;
+		break;
+        case CS_ERR_BUSY:
+		errno = EBUSY;
+		break;
+        case CS_ERR_ACCESS:
+		errno = EPERM;
+		break;
+        case CS_ERR_NOT_EXIST:
+		errno = ENOENT;
+		break;
+        case CS_ERR_NAME_TOO_LONG:
+		errno = ENAMETOOLONG;
+		break;
+        case CS_ERR_EXIST:
+		errno = EEXIST;
+		break;
+        case CS_ERR_NO_SPACE:
+		errno = ENOSPC;
+		break;
+        case CS_ERR_INTERRUPT:
+		errno = EINTR;
+		break;
+	case CS_ERR_NAME_NOT_FOUND:
+		errno = ENOENT;
+		break;
+        case CS_ERR_NO_RESOURCES:
+		errno = ENOMEM;
+		break;
+        case CS_ERR_NOT_SUPPORTED:
+		errno = EOPNOTSUPP;
+		break;
+        case CS_ERR_BAD_OPERATION:
+		errno = EINVAL;
+		break;
+        case CS_ERR_FAILED_OPERATION:
+		errno = EIO;
+		break;
+        case CS_ERR_MESSAGE_ERROR:
+		errno = EIO;
+		break;
+        case CS_ERR_QUEUE_FULL:
+		errno = EXFULL;
+		break;
+        case CS_ERR_QUEUE_NOT_AVAILABLE:
+		errno = EINVAL;
+		break;
+        case CS_ERR_BAD_FLAGS:
+		errno = EINVAL;
+		break;
+        case CS_ERR_TOO_BIG:
+		errno = E2BIG;
+		break;
+        case CS_ERR_NO_SECTIONS:
+		errno = ENOMEM;
+		break;
+	default:
+		errno = EINVAL;
+		break;
+	}
+	return -1;
+}
+
+static char *print_csid(const char *csid)
+{
+	static char buf[128];
+	int id;
+
+	memcpy(&id, csid, sizeof(int));
+	sprintf(buf, "%d", id);
+	return buf;
+}
+
+static void cpg_deliver_callback (cpg_handle_t handle,
+				  struct cpg_name *groupName,
+				  uint32_t nodeid,
+				  uint32_t pid,
+				  void *msg,
+				  int msg_len)
+{
+	int target_nodeid;
+
+	memcpy(&target_nodeid, msg, COROSYNC_CSID_LEN);
+
+	DEBUGLOG("%u got message from nodeid %d for %d. len %d\n",
+		 our_nodeid, nodeid, target_nodeid, msg_len-4);
+
+	if (nodeid != our_nodeid)
+		if (target_nodeid == our_nodeid || target_nodeid == 0)
+			process_message(cluster_client, (char *)msg+COROSYNC_CSID_LEN,
+					msg_len-COROSYNC_CSID_LEN, (char*)&nodeid);
+}
+
+static void cpg_confchg_callback(cpg_handle_t handle,
+				 struct cpg_name *groupName,
+				 struct cpg_address *member_list, int member_list_entries,
+				 struct cpg_address *left_list, int left_list_entries,
+				 struct cpg_address *joined_list, int joined_list_entries)
+{
+	int i;
+	struct node_info *ninfo;
+
+	DEBUGLOG("confchg callback. %d joined, %d left, %d members\n",
+		 joined_list_entries, left_list_entries, member_list_entries);
+
+	for (i=0; i<joined_list_entries; i++) {
+		ninfo = dm_hash_lookup_binary(node_hash,
+					      (char *)&joined_list[i].nodeid,
+					      COROSYNC_CSID_LEN);
+		if (!ninfo) {
+			ninfo = malloc(sizeof(struct node_info));
+			if (!ninfo) {
+				break;
+			}
+			else {
+				ninfo->nodeid = joined_list[i].nodeid;
+				dm_hash_insert_binary(node_hash,
+						      (char *)&ninfo->nodeid,
+						      COROSYNC_CSID_LEN, ninfo);
+			}
+		}
+		ninfo->state = NODE_CLVMD;
+	}
+
+	for (i=0; i<left_list_entries; i++) {
+		ninfo = dm_hash_lookup_binary(node_hash,
+					      (char *)&left_list[i].nodeid,
+					      COROSYNC_CSID_LEN);
+		if (ninfo)
+			ninfo->state = NODE_DOWN;
+	}
+
+	for (i=0; i<member_list_entries; i++) {
+		if (member_list[i].nodeid == 0) continue;
+		ninfo = dm_hash_lookup_binary(node_hash,
+				(char *)&member_list[i].nodeid,
+				COROSYNC_CSID_LEN);
+		if (!ninfo) {
+			ninfo = malloc(sizeof(struct node_info));
+			if (!ninfo) {
+				break;
+			}
+			else {
+				ninfo->nodeid = member_list[i].nodeid;
+				dm_hash_insert_binary(node_hash,
+						(char *)&ninfo->nodeid,
+						COROSYNC_CSID_LEN, ninfo);
+			}
+		}
+		ninfo->state = NODE_CLVMD;
+	}
+
+	num_nodes = member_list_entries;
+}
+
+static int _init_cluster(void)
+{
+	cs_error_t err;
+
+	node_hash = dm_hash_create(100);
+
+	err = cpg_initialize(&cpg_handle,
+			     &cpg_callbacks);
+	if (err != CS_OK) {
+		syslog(LOG_ERR, "Cannot initialise Corosync CPG service: %d",
+		       err);
+		DEBUGLOG("Cannot initialise Corosync CPG service: %d", err);
+		return cs_to_errno(err);
+	}
+
+	err = quorum_initialize(&quorum_handle,
+				&quorum_callbacks);
+	if (err != CS_OK) {
+		syslog(LOG_ERR, "Cannot initialise Corosync quorum service: %d",
+		       err);
+		DEBUGLOG("Cannot initialise Corosync quorum service: %d", err);
+		return cs_to_errno(err);
+	}
+
+
+	/* Create a lockspace for LV & VG locks to live in */
+	lockspace = dlm_create_lockspace(LOCKSPACE_NAME, 0600);
+	if (!lockspace) {
+		syslog(LOG_ERR, "Unable to create lockspace for CLVM: %m");
+		quorum_finalize(quorum_handle);
+		return -1;
+	}
+	dlm_ls_pthread_init(lockspace);
+	DEBUGLOG("DLM initialisation complete\n");
+
+	err = cpg_initialize(&cpg_handle, &cpg_callbacks);
+	if (err != CS_OK) {
+		return cs_to_errno(err);
+	}
+
+	/* Connect to the clvmd group */
+	strcpy((char *)cpg_group_name.value, "clvmd");
+	cpg_group_name.length = strlen((char *)cpg_group_name.value);
+	err = cpg_join(cpg_handle, &cpg_group_name);
+	if (err != CS_OK) {
+		cpg_finalize(cpg_handle);
+		quorum_finalize(quorum_handle);
+		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+		syslog(LOG_ERR, "Cannot join clvmd process group");
+		DEBUGLOG("Cannot join clvmd process group: %d\n", err);
+		return cs_to_errno(err);
+	}
+
+	err = cpg_local_get(cpg_handle,
+			    &our_nodeid);
+	if (err != CS_OK) {
+		cpg_finalize(cpg_handle);
+		quorum_finalize(quorum_handle);
+		dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+		syslog(LOG_ERR, "Cannot get local node id\n");
+		return cs_to_errno(err);
+	}
+	DEBUGLOG("Our local node id is %d\n", our_nodeid);
+
+	DEBUGLOG("Connected to Corosync\n");
+
+	return 0;
+}
+
+static void _cluster_closedown(void)
+{
+	DEBUGLOG("cluster_closedown\n");
+	unlock_all();
+
+	dlm_release_lockspace(LOCKSPACE_NAME, lockspace, 0);
+	cpg_finalize(cpg_handle);
+	quorum_finalize(quorum_handle);
+}
+
+static void _get_our_csid(char *csid)
+{
+	memcpy(csid, &our_nodeid, sizeof(int));
+}
+
+/* Corosync doesn't really have nmode names so we
+   just use the node ID in hex instead */
+static int _csid_from_name(char *csid, const char *name)
+{
+	int nodeid;
+	struct node_info *ninfo;
+
+	if (sscanf(name, "%x", &nodeid) == 1) {
+		ninfo = dm_hash_lookup_binary(node_hash, csid, COROSYNC_CSID_LEN);
+		if (ninfo)
+			return nodeid;
+	}
+	return -1;
+}
+
+static int _name_from_csid(const char *csid, char *name)
+{
+	struct node_info *ninfo;
+
+	ninfo = dm_hash_lookup_binary(node_hash, csid, COROSYNC_CSID_LEN);
+	if (!ninfo)
+	{
+		sprintf(name, "UNKNOWN %s", print_csid(csid));
+		return -1;
+	}
+
+	sprintf(name, "%x", ninfo->nodeid);
+	return 0;
+}
+
+static int _get_num_nodes()
+{
+	DEBUGLOG("num_nodes = %d\n", num_nodes);
+	return num_nodes;
+}
+
+/* Node is now known to be running a clvmd */
+static void _add_up_node(const char *csid)
+{
+	struct node_info *ninfo;
+
+	ninfo = dm_hash_lookup_binary(node_hash, csid, COROSYNC_CSID_LEN);
+	if (!ninfo) {
+		DEBUGLOG("corosync_add_up_node no node_hash entry for csid %s\n",
+			 print_csid(csid));
+		return;
+	}
+
+	DEBUGLOG("corosync_add_up_node %d\n", ninfo->nodeid);
+
+	ninfo->state = NODE_CLVMD;
+
+	return;
+}
+
+/* Call a callback for each node, so the caller knows whether it's up or down */
+static int _cluster_do_node_callback(struct local_client *master_client,
+				     void (*callback)(struct local_client *,
+						      const char *csid, int node_up))
+{
+	struct dm_hash_node *hn;
+	struct node_info *ninfo;
+	int somedown = 0;
+
+	dm_hash_iterate(hn, node_hash)
+	{
+		char csid[COROSYNC_CSID_LEN];
+
+		ninfo = dm_hash_get_data(node_hash, hn);
+		memcpy(csid, dm_hash_get_key(node_hash, hn), COROSYNC_CSID_LEN);
+
+		DEBUGLOG("down_callback. node %d, state = %d\n", ninfo->nodeid,
+			 ninfo->state);
+
+		if (ninfo->state != NODE_DOWN)
+			callback(master_client, csid, ninfo->state == NODE_CLVMD);
+		if (ninfo->state != NODE_CLVMD)
+			somedown = -1;
+	}
+	return somedown;
+}
+
+/* Real locking */
+static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
+{
+	struct dlm_lksb lksb;
+	int err;
+
+	DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n", resource, flags, mode);
+
+	if (flags & LKF_CONVERT)
+		lksb.sb_lkid = *lockid;
+
+	err = dlm_ls_lock_wait(lockspace,
+			       mode,
+			       &lksb,
+			       flags,
+			       resource,
+			       strlen(resource),
+			       0,
+			       NULL, NULL, NULL);
+
+	if (err != 0)
+	{
+		DEBUGLOG("dlm_ls_lock returned %d\n", errno);
+		return err;
+	}
+
+	DEBUGLOG("lock_resource returning %d, lock_id=%x\n", err, lksb.sb_lkid);
+
+	*lockid = lksb.sb_lkid;
+
+	return 0;
+}
+
+
+static int _unlock_resource(const char *resource, int lockid)
+{
+	struct dlm_lksb lksb;
+	int err;
+
+	DEBUGLOG("unlock_resource: %s lockid: %x\n", resource, lockid);
+	lksb.sb_lkid = lockid;
+
+	err = dlm_ls_unlock_wait(lockspace,
+				 lockid,
+				 0,
+				 &lksb);
+	if (err != 0)
+	{
+		DEBUGLOG("Unlock returned %d\n", err);
+		return err;
+	}
+
+	return 0;
+}
+
+/* We are always quorate ! */
+static int _is_quorate()
+{
+	int quorate;
+	if (quorum_getquorate(quorum_handle, &quorate) == CS_OK)
+		return quorate;
+	else
+		return 0;
+}
+
+static int _get_main_cluster_fd(void)
+{
+	int select_fd;
+
+	cpg_fd_get(cpg_handle, &select_fd);
+	return select_fd;
+}
+
+static int _cluster_fd_callback(struct local_client *fd, char *buf, int len,
+				const char *csid,
+				struct local_client **new_client)
+{
+	cluster_client = fd;
+	*new_client = NULL;
+	cpg_dispatch(cpg_handle, CS_DISPATCH_ONE);
+	return 1;
+}
+
+static int _cluster_send_message(const void *buf, int msglen, const char *csid,
+				 const char *errtext)
+{
+	struct iovec iov[2];
+	cs_error_t err;
+	int target_node;
+
+	if (csid)
+		memcpy(&target_node, csid, COROSYNC_CSID_LEN);
+	else
+		target_node = 0;
+
+	iov[0].iov_base = &target_node;
+	iov[0].iov_len = sizeof(int);
+	iov[1].iov_base = (char *)buf;
+	iov[1].iov_len = msglen;
+
+	err = cpg_mcast_joined(cpg_handle, CPG_TYPE_AGREED, iov, 2);
+	return cs_to_errno(err);
+}
+
+/* We don't have a cluster name to report here */
+static int _get_cluster_name(char *buf, int buflen)
+{
+	strncpy(buf, "Corosync", buflen);
+	return 0;
+}
+
+static struct cluster_ops _cluster_corosync_ops = {
+	.cluster_init_completed   = NULL,
+	.cluster_send_message     = _cluster_send_message,
+	.name_from_csid           = _name_from_csid,
+	.csid_from_name           = _csid_from_name,
+	.get_num_nodes            = _get_num_nodes,
+	.cluster_fd_callback      = _cluster_fd_callback,
+	.get_main_cluster_fd      = _get_main_cluster_fd,
+	.cluster_do_node_callback = _cluster_do_node_callback,
+	.is_quorate               = _is_quorate,
+	.get_our_csid             = _get_our_csid,
+	.add_up_node              = _add_up_node,
+	.reread_config            = NULL,
+	.cluster_closedown        = _cluster_closedown,
+	.get_cluster_name         = _get_cluster_name,
+	.sync_lock                = _lock_resource,
+	.sync_unlock              = _unlock_resource,
+};
+
+struct cluster_ops *init_corosync_cluster(void)
+{
+	if (!_init_cluster())
+		return &_cluster_corosync_ops;
+	else
+		return NULL;
+}
--- LVM2/daemons/clvmd/Makefile.in	2008/10/07 19:11:59	1.24
+++ LVM2/daemons/clvmd/Makefile.in	2009/01/22 10:21:12	1.25
@@ -39,6 +39,14 @@
 	GULM = yes
 	CMAN = yes
 	OPENAIS = no
+	COROSYNC = no
+endif
+
+ifeq ("@CLVMD@", "corosync")
+	GULM = no
+	CMAN = no
+	OPENAIS = no
+	COROSYNC = yes
 endif
 
 ifeq ("@DEBUG@", "yes")
@@ -63,6 +71,13 @@
 	DEFS += -DUSE_OPENAIS
 endif
 
+ifeq ("$(COROSYNC)", "yes")
+        SOURCES += clvmd-corosync.c
+        LMLIBS += -lquorum -lcpg -ldlm
+        DEFS += -DUSE_COROSYNC
+endif
+
+
 TARGETS = \
 	clvmd
 
--- LVM2/daemons/clvmd/clvmd-comms.h	2007/05/21 10:52:01	1.8
+++ LVM2/daemons/clvmd/clvmd-comms.h	2009/01/22 10:21:12	1.9
@@ -93,5 +93,22 @@
 struct cluster_ops *init_openais_cluster(void);
 #endif
 
+#ifdef USE_COROSYNC
+#  include <corosync/corotypes.h>
+#  define COROSYNC_CSID_LEN (sizeof(int))
+#  define COROSYNC_MAX_CLUSTER_MESSAGE         65535
+#  define COROSYNC_MAX_CLUSTER_MEMBER_NAME_LEN CS_MAX_NAME_LENGTH
+#  ifndef MAX_CLUSTER_MEMBER_NAME_LEN
+#    define MAX_CLUSTER_MEMBER_NAME_LEN       CS_MAX_NAME_LENGTH
+#  endif
+#  ifndef CMAN_MAX_CLUSTER_MESSAGE
+#    define CMAN_MAX_CLUSTER_MESSAGE          65535
+#  endif
+#  ifndef MAX_CSID_LEN
+#    define MAX_CSID_LEN sizeof(int)
+#  endif
+struct cluster_ops *init_corosync_cluster(void);
+#endif
+
 
 #endif
--- LVM2/daemons/clvmd/clvmd.c	2008/11/21 13:48:00	1.52
+++ LVM2/daemons/clvmd/clvmd.c	2009/01/22 10:21:12	1.53
@@ -391,6 +391,15 @@
 			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to OpenAIS");
 		}
 #endif
+#ifdef USE_COROSYNC
+	if (!clops)
+		if ((clops = init_corosync_cluster())) {
+			max_csid_len = COROSYNC_CSID_LEN;
+			max_cluster_message = COROSYNC_MAX_CLUSTER_MESSAGE;
+			max_cluster_member_name_len = COROSYNC_MAX_CLUSTER_MEMBER_NAME_LEN;
+			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to Corosync");
+		}
+#endif
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");


