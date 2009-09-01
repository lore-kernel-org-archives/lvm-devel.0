From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 1 Sep 2009 09:48:02 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20090901094802.8532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-09-01 09:48:01

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Add some code to clvmd to look in the corosync confdb to see what cluster
	interface it should be using, it can still be overriden with -I.
	
	If corosync isn't running or there is no information then the usual
	checking will happen.
	
	This code only builds if corosync is available.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1246&r2=1.1247
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2009/08/28 20:51:40	1.1246
+++ LVM2/WHATS_NEW	2009/09/01 09:48:01	1.1247
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Make clvmd check corosync to see what cluster interface it should use.
   Rewrite clvmd configuration code to cope with all combinations of libs.
   Fix global locking in PV reporting commands (2.02.49).
   Fix pvcreate string termination in duplicate uuid warning message.
--- LVM2/daemons/clvmd/clvmd.c	2009/08/13 10:39:41	1.60
+++ LVM2/daemons/clvmd/clvmd.c	2009/09/01 09:48:01	1.61
@@ -44,7 +44,9 @@
 #include <syslog.h>
 #include <errno.h>
 #include <limits.h>
-#include <libdlm.h>
+#ifdef HAVE_COROSYNC_CONFDB_H
+#include <corosync/confdb.h>
+#endif
 
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
@@ -149,6 +151,7 @@
 static void add_reply_to_list(struct local_client *client, int status,
 			      const char *csid, const char *buf, int len);
 static if_type_t parse_cluster_interface(char *ifname);
+static if_type_t get_cluster_type(void);
 
 static void usage(char *prog, FILE *file)
 {
@@ -392,6 +395,9 @@
 	init_lvhash();
 
 	/* Start the cluster interface */
+	if (cluster_iface == IF_AUTO)
+		cluster_iface = get_cluster_type();
+
 #ifdef USE_CMAN
 	if ((cluster_iface == IF_AUTO || cluster_iface == IF_CMAN) && (clops = init_cman_cluster())) {
 		max_csid_len = CMAN_MAX_CSID_LEN;
@@ -2060,3 +2066,59 @@
 
 	return iface;
 }
+
+/*
+ * Try and find a cluster system in corosync's objdb, if it is running. This is
+ * only called if the command-line option is not present, and if it fails
+ * we still try the interfaces in order.
+ */
+static if_type_t get_cluster_type()
+{
+#ifdef HAVE_COROSYNC_CONFDB_H
+	confdb_handle_t handle;
+	if_type_t type = IF_AUTO;
+	int result;
+	char buf[255];
+	size_t namelen = sizeof(buf);
+	hdb_handle_t cluster_handle;
+	hdb_handle_t clvmd_handle;
+	confdb_callbacks_t callbacks = {
+		.confdb_key_change_notify_fn = NULL,
+		.confdb_object_create_change_notify_fn = NULL,
+		.confdb_object_delete_change_notify_fn = NULL
+	};
+
+	result = confdb_initialize (&handle, &callbacks);
+        if (result != CS_OK)
+		return type;
+
+        result = confdb_object_find_start(handle, OBJECT_PARENT_HANDLE);
+	if (result != CS_OK)
+		goto out;
+
+        result = confdb_object_find(handle, OBJECT_PARENT_HANDLE, (void *)"cluster", strlen("cluster"), &cluster_handle);
+        if (result != CS_OK)
+		goto out;
+
+        result = confdb_object_find_start(handle, cluster_handle);
+	if (result != CS_OK)
+		goto out;
+
+        result = confdb_object_find(handle, cluster_handle, (void *)"clvmd", strlen("clvmd"), &clvmd_handle);
+        if (result != CS_OK)
+		goto out;
+
+        result = confdb_key_get(handle, clvmd_handle, (void *)"interface", strlen("interface"), buf, &namelen);
+        if (result != CS_OK)
+		goto out;
+
+	buf[namelen] = '\0';
+	type = parse_cluster_interface(buf);
+	DEBUGLOG("got interface type '%s' from confdb\n", buf);
+out:
+	confdb_finalize(handle);
+	return type;
+#else
+	return IF_AUTO;
+#endif
+}


