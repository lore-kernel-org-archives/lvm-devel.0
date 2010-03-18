From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Mar 2010 09:19:36 -0000
Subject: LVM2 ./configure.in daemons/clvmd/Makefile.in ...
Message-ID: <20100318091936.9823.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-18 09:19:33

Modified files:
	.              : configure.in 
	daemons/clvmd  : Makefile.in clvmd-comms.h clvmd.c 
	lib/misc       : configure.h.in 
	test           : Makefile.in test-utils.sh 
Added files:
	daemons/clvmd  : clvmd-singlenode.c 

Log message:
	Add infrastructure for running the functional testsuite with locking_type set
	to 3, using a local (singlenode) clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/configure.in	2010/03/04 12:12:34	1.131
+++ LVM2/configure.in	2010/03/18 09:19:30	1.132
@@ -340,6 +340,7 @@
                            * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
+                           * singlenode            (localhost only)
                            * all                   (autodetect)
                            * none                  (disable build)
                           [TYPE=none] ],
/cvs/lvm2/LVM2/daemons/clvmd/clvmd-singlenode.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/clvmd/clvmd-singlenode.c
+++ -	2010-03-18 09:19:34.163466000 +0000
@@ -0,0 +1,252 @@
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
+#define _GNU_SOURCE
+#define _FILE_OFFSET_BITS 64
+
+#include <netinet/in.h>
+#include <sys/un.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <configure.h>
+#include <libdevmapper.h>
+
+#include <pthread.h>
+
+#include "locking.h"
+#include "lvm-logging.h"
+#include "clvm.h"
+#include "clvmd-comms.h"
+#include "lvm-functions.h"
+#include "clvmd.h"
+
+static int listen_fd = -1;
+
+static int init_comms()
+{
+	listen_fd = open("/dev/null", O_RDWR);
+
+	if (listen_fd < 0)
+		return -1;
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
+
+	DEBUGLOG("Single-node cluster initialised.\n");
+	return 0;
+}
+
+static void _cluster_closedown(void)
+{
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
+int _lock_file(const char *file, uint32_t flags);
+
+static int *_locks = NULL;
+static char **_resources = NULL;
+static int _lock_max = 1;
+static pthread_mutex_t _lock_mutex = PTHREAD_MUTEX_INITIALIZER;
+
+/* Real locking */
+static int _lock_resource(const char *resource, int mode, int flags, int *lockid)
+{
+	int *_locks_1;
+	char **_resources_1;
+	int i, j;
+
+	DEBUGLOG("lock_resource '%s', flags=%d, mode=%d\n",
+		 resource, flags, mode);
+
+ retry:
+	pthread_mutex_lock(&_lock_mutex);
+
+	/* look for an existing lock for this resource */
+	for (i = 1; i < _lock_max; ++i) {
+		if (!_resources[i])
+			break;
+		if (!strcmp(_resources[i], resource)) {
+			if ((_locks[i] & LCK_WRITE) || (_locks[i] & LCK_EXCL)) {
+				DEBUGLOG("%s already write/exclusively locked...\n", resource);
+				goto maybe_retry;
+			}
+			if ((mode & LCK_WRITE) || (mode & LCK_EXCL)) {
+				DEBUGLOG("%s already locked and WRITE/EXCL lock requested...\n",
+					 resource);
+				goto maybe_retry;
+			}
+		}
+	}
+
+	if (i == _lock_max) { /* out of lock slots, extend */
+		_locks_1 = dm_realloc(_locks, 2 * _lock_max * sizeof(int));
+		if (!_locks_1)
+			return 1; /* fail */
+		_locks = _locks_1;
+		_resources_1 = dm_realloc(_resources, 2 * _lock_max * sizeof(char *));
+		if (!_resources_1) {
+			/* _locks may get realloc'd twice, but that should be safe */
+			return 1; /* fail */
+		}
+		_resources = _resources_1;
+		/* clear the new resource entries */
+		for (j = _lock_max; j < 2 * _lock_max; ++j)
+			_resources[j] = NULL;
+		_lock_max = 2 * _lock_max;
+	}
+
+	/* resource is not currently locked, grab it */
+
+	*lockid = i;
+	_locks[i] = mode;
+	_resources[i] = dm_strdup(resource);
+
+	DEBUGLOG("%s locked -> %d\n", resource, i);
+
+	pthread_mutex_unlock(&_lock_mutex);
+	return 0;
+ maybe_retry:
+	pthread_mutex_unlock(&_lock_mutex);
+	if (!(flags & LCK_NONBLOCK)) {
+		usleep(10000);
+		goto retry;
+	}
+
+	return 1; /* fail */
+}
+
+static int _unlock_resource(const char *resource, int lockid)
+{
+	DEBUGLOG("unlock_resource: %s lockid: %x\n", resource, lockid);
+	if(!_resources[lockid]) {
+		DEBUGLOG("(%s) %d not locked\n", resource, lockid);
+		return 1;
+	}
+	if(strcmp(_resources[lockid], resource)) {
+		DEBUGLOG("%d has wrong resource (requested %s, got %s)\n",
+			 lockid, resource, _resources[lockid]);
+		return 1;
+	}
+
+	dm_free(_resources[lockid]);
+	_resources[lockid] = 0;
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
+	strncpy(buf, "localcluster", buflen);
+	buf[buflen - 1] = 0;
+	return 0;
+}
+
+static struct cluster_ops _cluster_singlenode_ops = {
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
+struct cluster_ops *init_singlenode_cluster(void)
+{
+	if (!_init_cluster())
+		return &_cluster_singlenode_ops;
+	else
+		return NULL;
+}
--- LVM2/daemons/clvmd/Makefile.in	2010/03/16 08:47:47	1.36
+++ LVM2/daemons/clvmd/Makefile.in	2010/03/18 09:19:31	1.37
@@ -71,6 +71,10 @@
 	DEFS += -DUSE_COROSYNC
 endif
 
+ifneq (,$(findstring singlenode,, &quot;@CLVMD@,&quot;))
+	SOURCES += clvmd-singlenode.c
+	DEFS += -DUSE_SINGLENODE
+endif
 
 TARGETS = \
 	clvmd
--- LVM2/daemons/clvmd/clvmd-comms.h	2009/08/28 19:22:05	1.10
+++ LVM2/daemons/clvmd/clvmd-comms.h	2010/03/18 09:19:31	1.11
@@ -110,5 +110,12 @@
 struct cluster_ops *init_corosync_cluster(void);
 #endif
 
+#ifdef USE_SINGLENODE
+#  define SINGLENODE_CSID_LEN (sizeof(int))
+#  define MAX_CLUSTER_MEMBER_NAME_LEN       64
+#  define SINGLENODE_MAX_CLUSTER_MESSAGE          65535
+#  define MAX_CSID_LEN sizeof(int)
+struct cluster_ops *init_singlenode_cluster(void);
+#endif
 
 #endif
--- LVM2/daemons/clvmd/clvmd.c	2010/02/02 08:54:29	1.63
+++ LVM2/daemons/clvmd/clvmd.c	2010/03/18 09:19:31	1.64
@@ -110,7 +110,7 @@
 #define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
-typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC} if_type_t;
+typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
 
 typedef void *(lvm_pthread_fn_t)(void*);
 
@@ -180,6 +180,9 @@
 #ifdef USE_GULM
 	fprintf(file, "gulm ");
 #endif
+#ifdef USE_SINGLENODE
+	fprintf(file, "singlenode");
+#endif
 	fprintf(file, "\n");
 }
 
@@ -434,6 +437,15 @@
 			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to OpenAIS");
 		}
 #endif
+#ifdef USE_SINGLENODE
+	if (!clops)
+		if ((cluster_iface == IF_AUTO || cluster_iface == IF_SINGLENODE) && (clops = init_singlenode_cluster())) {
+			max_csid_len = SINGLENODE_CSID_LEN;
+			max_cluster_message = SINGLENODE_MAX_CLUSTER_MESSAGE;
+			max_cluster_member_name_len = MAX_CLUSTER_MEMBER_NAME_LEN;
+			syslog(LOG_NOTICE, "Cluster LVM daemon started - running in single-node mode");
+		}
+#endif
 
 	if (!clops) {
 		DEBUGLOG("Can't initialise cluster interface\n");
@@ -2063,6 +2075,8 @@
 		iface = IF_OPENAIS;
 	if (!strcmp(ifname, "corosync"))
 		iface = IF_COROSYNC;
+	if (!strcmp(ifname, "singlenode"))
+		iface = IF_SINGLENODE;
 
 	return iface;
 }
--- LVM2/lib/misc/configure.h.in	2010/03/04 11:19:15	1.16
+++ LVM2/lib/misc/configure.h.in	2010/03/18 09:19:32	1.17
@@ -270,7 +270,7 @@
 /* Define to 1 if you have the `strtoul' function. */
 #undef HAVE_STRTOUL
 
-/* Define to 1 if `st_rdev' is member of `struct stat'. */
+/* Define to 1 if `struct stat' is a member of `st_rdev'. */
 #undef HAVE_STRUCT_STAT_ST_RDEV
 
 /* Define to 1 if you have the <syslog.h> header file. */
@@ -407,6 +407,9 @@
 /* Define to the one symbol short name of this package. */
 #undef PACKAGE_TARNAME
 
+/* Define to the home page for this package. */
+#undef PACKAGE_URL
+
 /* Define to the version of this package. */
 #undef PACKAGE_VERSION
 
--- LVM2/test/Makefile.in	2010/02/15 16:30:13	1.26
+++ LVM2/test/Makefile.in	2010/03/18 09:19:33	1.27
@@ -42,7 +42,10 @@
 endif
 
 all: init.sh
-	./bin/harness t-*.sh
+	@echo Testing with locking_type 1
+	#./bin/harness t-*.sh
+	@echo Testing with locking_type 3
+	LVM_TEST_LOCKING=3 ./bin/harness t-*.sh
 
 bin/not: $(srcdir)/not.c .bin-dir-stamp
 	$(CC) -o bin/not $<
@@ -77,6 +80,7 @@
 	  ln -s ../lvm-wrapper bin/$$i; \
 	done
 	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
+	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
 	touch $@
 
 lvm-wrapper: Makefile
--- LVM2/test/test-utils.sh	2010/03/17 14:55:28	1.22
+++ LVM2/test/test-utils.sh	2010/03/18 09:19:33	1.23
@@ -54,10 +54,31 @@
 	fi
 }
 
+prepare_clvmd() {
+	if test -z "$LVM_TEST_LOCKING" || test "$LVM_TEST_LOCKING" -ne 3 ; then
+		return 0 # not needed
+	fi
+
+	if pgrep clvmd ; then
+		echo "Cannot use fake cluster locking with real clvmd ($(pgrep clvmd)) running."
+		exit 1
+	fi
+
+	# skip if we don't have our own clvmd...
+	(which clvmd | grep $abs_builddir) || exit 200
+
+	trap 'aux teardown_' EXIT # don't forget to clean up
+
+	clvmd -Isinglenode -d 1 &
+	LOCAL_CLVMD="$!"
+}
+
 teardown() {
 	echo $LOOP
 	echo $PREFIX
 
+	test -n "$LOCAL_CLVMD" && kill -9 "$LOCAL_CLVMD"
+
 	test -n "$PREFIX" && {
 		rm -rf $G_root_/dev/$PREFIX*
 
@@ -288,6 +309,8 @@
 	local filter="$1"
 	test -z "$filter" && \
 		filter='[ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
+        locktype=
+	if test -n "$LVM_TEST_LOCKING"; then locktype="locking_type = $LVM_TEST_LOCKING"; fi
 	cat > $G_root_/etc/lvm.conf <<-EOF
   devices {
     dir = "$G_dev_"
@@ -309,6 +332,7 @@
     abort_on_internal_errors = 1
     library_dir = "$G_root_/lib"
     locking_dir = "$G_root_/var/lock/lvm"
+    $locktype
   }
   activation {
     udev_sync = 1
@@ -319,4 +343,5 @@
 
 set -vexE -o pipefail
 aux prepare_lvmconf
+prepare_clvmd
 


