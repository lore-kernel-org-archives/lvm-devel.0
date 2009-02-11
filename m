From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 11 Feb 2009 10:13:21 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in dae ...
Message-ID: <20090211101321.19616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-02-11 10:13:21

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in clvmd-corosync.c 

Log message:
	Add a fully-functional get_cluster_name() to clvmd corosync interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1041&r2=1.1042
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2009/02/10 13:22:18	1.1041
+++ LVM2/WHATS_NEW	2009/02/11 10:13:20	1.1042
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add a fully-functional get_cluster_name() to clvmd corosync interface.
   Remove duplicate cpg_initialize from clvmd startup.
   Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
   Allow clvmd to start up if its lockspace already exists.
--- LVM2/daemons/clvmd/Makefile.in	2009/02/02 14:34:25	1.26
+++ LVM2/daemons/clvmd/Makefile.in	2009/02/11 10:13:20	1.27
@@ -68,7 +68,7 @@
 
 ifeq ("$(COROSYNC)", "yes")
         SOURCES += clvmd-corosync.c
-        LMLIBS += -lquorum -lcpg -ldlm
+        LMLIBS += -lquorum -lconfdb -lcpg -ldlm
         DEFS += -DUSE_COROSYNC
 endif
 
--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/10 13:22:18	1.4
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/02/11 10:13:20	1.5
@@ -42,6 +42,7 @@
 #include <corosync/corotypes.h>
 #include <corosync/cpg.h>
 #include <corosync/quorum.h>
+#include <corosync/confdb.h>
 #include <libdlm.h>
 
 #include "locking.h"
@@ -507,7 +508,6 @@
 	return 0;
 }
 
-/* We are always quorate ! */
 static int _is_quorate()
 {
 	int quorate;
@@ -556,10 +556,49 @@
 	return cs_to_errno(err);
 }
 
-/* We don't have a cluster name to report here */
+/*
+ * We are not necessarily connected to a Red Hat Cluster system,
+ * but if we are, this returns the cluster name from cluster.conf.
+ * I've used confdb rather than ccs to reduce the inter-package
+ * dependancies as well as to allow people to set a cluster name
+ * for themselves even if they are not running on RH cluster.
+ */
 static int _get_cluster_name(char *buf, int buflen)
 {
+	confdb_handle_t handle;
+	int result;
+	int namelen = buflen;
+	unsigned int cluster_handle;
+	confdb_callbacks_t callbacks = {
+		.confdb_key_change_notify_fn = NULL,
+		.confdb_object_create_change_notify_fn = NULL,
+		.confdb_object_delete_change_notify_fn = NULL
+	};
+
+	/* This is a default in case everything else fails */
 	strncpy(buf, "Corosync", buflen);
+
+	/* Look for a cluster name in confdb */
+	result = confdb_initialize (&handle, &callbacks);
+        if (result != CS_OK)
+		return 0;
+
+        result = confdb_object_find_start(handle, OBJECT_PARENT_HANDLE);
+	if (result != CS_OK)
+		goto out;
+
+        result = confdb_object_find(handle, OBJECT_PARENT_HANDLE, (void *)"cluster", strlen("cluster"), &cluster_handle);
+        if (result != CS_OK)
+		goto out;
+
+        result = confdb_key_get(handle, cluster_handle, (void *)"name", strlen("name"), buf, &namelen);
+        if (result != CS_OK)
+		goto out;
+
+	buf[namelen] = '\0';
+
+out:
+	confdb_finalize(handle);
 	return 0;
 }
 


