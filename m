From: Milan Broz <mbroz@redhat.com>
Date: Mon, 22 Feb 2010 15:55:25 +0100
Subject: [PATCH 1/2] Add "fake" cluster locking (local locking performed in clvmd) for testing.
Message-ID: <1266850526-31583-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch introduces simple "cluster" locking, which basically
simulates only one node to allow clvmd running even withou any cluster
infrastucture.

The puprose of this patch is to provide very simple testin environment
for cluster locking.
Basically the locking is performed from long-running clvmd process.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 configure.in                |    1 +
 daemons/clvmd/Makefile.in   |    4 +
 daemons/clvmd/clvmd-comms.h |    7 ++
 daemons/clvmd/clvmd-fake.c  |  191 +++++++++++++++++++++++++++++++++++++++++++
 daemons/clvmd/clvmd.c       |   16 ++++-
 5 files changed, 218 insertions(+), 1 deletions(-)
 create mode 100644 daemons/clvmd/clvmd-fake.c

diff --git a/configure.in b/configure.in
index aaa21c6..6ea2e33 100644
--- a/configure.in
+++ b/configure.in
@@ -342,6 +342,7 @@ AC_ARG_WITH(clvmd,
                            * cman,corosync,openais (or selection of them)
                            * all                   (autodetect)
                            * none                  (disable build)
+                           * fake                  (debugging only)
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index dad568e..04aa6fc 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -71,6 +71,10 @@ ifneq (,$(findstring corosync,, "@CLVMD@,"))
 	DEFS += -DUSE_COROSYNC
 endif
 
+ifneq (,$(findstring fake,, "@CLVMD@,"))
+	SOURCES += clvmd-fake.c
+	DEFS += -DUSE_FAKE
+endif
 
 TARGETS = \
 	clvmd
diff --git a/daemons/clvmd/clvmd-comms.h b/daemons/clvmd/clvmd-comms.h
index cc5def5..72e3ed2 100644
--- a/daemons/clvmd/clvmd-comms.h
+++ b/daemons/clvmd/clvmd-comms.h
@@ -110,5 +110,12 @@ struct cluster_ops *init_openais_cluster(void);
 struct cluster_ops *init_corosync_cluster(void);
 #endif
 
+#ifdef USE_FAKE
+#  define FAKE_CSID_LEN (sizeof(int))
+#  define MAX_CLUSTER_MEMBER_NAME_LEN       64
+#  define FAKE_MAX_CLUSTER_MESSAGE          65535
+#  define MAX_CSID_LEN sizeof(int)
+struct cluster_ops *init_fake_cluster(void);
+#endif
 
 #endif
diff --git a/daemons/clvmd/clvmd-fake.c b/daemons/clvmd/clvmd-fake.c
new file mode 100644
index 0000000..4145f6a
--- /dev/null
+++ b/daemons/clvmd/clvmd-fake.c
@@ -0,0 +1,191 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This provides the fake interface for locking manager
+ */
+
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <netinet/in.h>
+#include <sys/un.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <configure.h>
+#include <libdevmapper.h>
+
+#include "locking.h"
+#include "lvm-logging.h"
+#include "clvm.h"
+#include "clvmd-comms.h"
+#include "lvm-functions.h"
+#include "clvmd.h"
+
+#define SOCKET_PATH     "/fakeclvmd"
+static int listen_fd = -1;
+
+static int init_comms()
+{
+	struct  sockaddr_un addr;
+
+	listen_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
+
+	if (listen_fd < 0)
+		return -1;
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	strcpy(addr.sun_path, SOCKET_PATH);
+
+	unlink(SOCKET_PATH);
+	if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
+		DEBUGLOG("Can't bind to port: %s\n", strerror(errno));
+		close(listen_fd);
+		return -1;
+	}
+
+	listen(listen_fd, 5);
+
+	/* Set Close-on-exec */
+	fcntl(listen_fd, F_SETFD, 1);
+
+	return 0;
+}
+
+static int _init_cluster(void)
+{
+	int r;
+
+	r = init_comms();
+	if (r)
+		return r;
+	DEBUGLOG("Connected to fakecluster\n");
+	return 0;
+}
+
+static void _cluster_closedown(void)
+{
+	unlink(SOCKET_PATH);
+	close(listen_fd);
+
+	DEBUGLOG("cluster_closedown\n");
+	destroy_lvhash();
+}
+
+static void _get_our_csid(char *csid)
+{
+	int nodeid = 1;
+	memcpy(csid, &nodeid, sizeof(int));
+}
+
+static int _csid_from_name(char *csid, const char *name)
+{
+	return 1;
+}
+
+static int _name_from_csid(const char *csid, char *name)
+{
+	sprintf(name, "%x", 0xdead);
+	return 0;
+}
+
+static int _get_num_nodes()
+{
+	return 1;
+}
+
+/* Node is now known to be running a clvmd */
+static void _add_up_node(const char *csid)
+{
+}
+
+/* Call a callback for each node, so the caller knows whether it's up or down */
+static int _cluster_do_node_callback(struct local_client *master_client,
+				     void (*callback)(struct local_client *,
+				     const char *csid, int node_up))
+{
+	return 0;
+}
+
+/* Real locking */
+static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
+{
+	DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n", resource, flags, mode);
+	return 0;
+}
+
+static int _unlock_resource(const char *resource, int lockid)
+{
+	DEBUGLOG("unlock_resource: %s lockid: %x\n", resource, lockid);
+	return 0;
+}
+
+static int _is_quorate()
+{
+	return 1;
+}
+
+static int _get_main_cluster_fd(void)
+{
+	return listen_fd;
+}
+
+static int _cluster_fd_callback(struct local_client *fd, char *buf, int len,
+				const char *csid,
+				struct local_client **new_client)
+{
+	return 1;
+}
+
+static int _cluster_send_message(const void *buf, int msglen,
+				 const char *csid,
+				 const char *errtext)
+{
+	return 0;
+}
+
+static int _get_cluster_name(char *buf, int buflen)
+{
+	strncpy(buf, "fakecluster", buflen);
+	return 0;
+}
+
+static struct cluster_ops _cluster_fake_ops = {
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
+struct cluster_ops *init_fake_cluster(void)
+{
+	if (!_init_cluster())
+		return &_cluster_fake_ops;
+	else
+		return NULL;
+}
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9471935..5cca3b4 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -110,7 +110,7 @@ static int child_pipe[2];
 #define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
-typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC} if_type_t;
+typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_FAKE} if_type_t;
 
 typedef void *(lvm_pthread_fn_t)(void*);
 
@@ -180,6 +180,9 @@ static void usage(char *prog, FILE *file)
 #ifdef USE_GULM
 	fprintf(file, "gulm ");
 #endif
+#ifdef USE_FAKE
+	fprintf(file, "fake ");
+#endif
 	fprintf(file, "\n");
 }
 
@@ -434,6 +437,15 @@ int main(int argc, char *argv[])
 			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to OpenAIS");
 		}
 #endif
+#ifdef USE_FAKE
+	if (!clops)
+		if ((cluster_iface == IF_AUTO || cluster_iface == IF_FAKE) && (clops = init_fake_cluster())) {
+			max_csid_len = FAKE_CSID_LEN;
+			max_cluster_message = FAKE_MAX_CLUSTER_MESSAGE;
+			max_cluster_member_name_len = MAX_CLUSTER_MEMBER_NAME_LEN;
+			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to FakeCluster");
+		}
+#endif
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
@@ -2063,6 +2075,8 @@ static if_type_t parse_cluster_interface(char *ifname)
 		iface = IF_OPENAIS;
 	if (!strcmp(ifname, "corosync"))
 		iface = IF_COROSYNC;
+	if (!strcmp(ifname, "fake"))
+		iface = IF_FAKE;
 
 	return iface;
 }
-- 
1.7.0


