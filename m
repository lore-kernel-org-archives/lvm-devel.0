From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:36 +0200
Subject: [PATCH 15/15] Allow corosync and openais backends to co-exist
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <29d398440858ab9968455bcc165624a43763a81d.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The openais backend uses cpg and SaLck from the old
openais whitetank branch. The SaLck service is known
to be broken in any version of openais < 1.0 and
it will never be fixed.

Port the openais code to the new corosync cpg api so that it
can be built with openais > 1.0 and working SaLck.

Rename cpg call back functions in both openais and corosync
locking backends to avoid clashes at link time.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 3de278d... cc5def5... M	daemons/clvmd/clvmd-comms.h
:100644 100644 be8ff78... 239942c... M	daemons/clvmd/clvmd-corosync.c
:100644 100644 3101069... 7c058a8... M	daemons/clvmd/clvmd-openais.c
 daemons/clvmd/clvmd-comms.h    |    4 +-
 daemons/clvmd/clvmd-corosync.c |   16 ++++++------
 daemons/clvmd/clvmd-openais.c  |   49 +++++++++++++++++++++------------------
 3 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/daemons/clvmd/clvmd-comms.h b/daemons/clvmd/clvmd-comms.h
index 3de278d..cc5def5 100644
--- a/daemons/clvmd/clvmd-comms.h
+++ b/daemons/clvmd/clvmd-comms.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -77,7 +77,7 @@ struct cluster_ops *init_cman_cluster(void);
 
 #ifdef USE_OPENAIS
 #  include <openais/saAis.h>
-#  include <openais/totem/totem.h>
+#  include <corosync/totem/totem.h>
 #  define OPENAIS_CSID_LEN (sizeof(int))
 #  define OPENAIS_MAX_CLUSTER_MESSAGE         MESSAGE_SIZE_MAX
 #  define OPENAIS_MAX_CLUSTER_MEMBER_NAME_LEN SA_MAX_NAME_LENGTH
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index be8ff78..239942c 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -55,13 +55,13 @@
 /* Timeout value for several corosync calls */
 #define LOCKSPACE_NAME "clvmd"
 
-static void cpg_deliver_callback (cpg_handle_t handle,
+static void corosync_cpg_deliver_callback (cpg_handle_t handle,
 				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
 				  size_t msg_len);
-static void cpg_confchg_callback(cpg_handle_t handle,
+static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 				 const struct cpg_name *groupName,
 				 const struct cpg_address *member_list, size_t member_list_entries,
 				 const struct cpg_address *left_list, size_t left_list_entries,
@@ -87,9 +87,9 @@ static dlm_lshandle_t *lockspace;
 static struct cpg_name cpg_group_name;
 
 /* Corosync callback structs */
-cpg_callbacks_t cpg_callbacks = {
-	.cpg_deliver_fn =            cpg_deliver_callback,
-	.cpg_confchg_fn =            cpg_confchg_callback,
+cpg_callbacks_t corosync_cpg_callbacks = {
+	.cpg_deliver_fn =            corosync_cpg_deliver_callback,
+	.cpg_confchg_fn =            corosync_cpg_confchg_callback,
 };
 
 quorum_callbacks_t quorum_callbacks = {
@@ -205,7 +205,7 @@ static char *print_corosync_csid(const char *csid)
 	return buf;
 }
 
-static void cpg_deliver_callback (cpg_handle_t handle,
+static void corosync_cpg_deliver_callback (cpg_handle_t handle,
 				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
@@ -225,7 +225,7 @@ static void cpg_deliver_callback (cpg_handle_t handle,
 					msg_len-COROSYNC_CSID_LEN, (char*)&nodeid);
 }
 
-static void cpg_confchg_callback(cpg_handle_t handle,
+static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 				 const struct cpg_name *groupName,
 				 const struct cpg_address *member_list, size_t member_list_entries,
 				 const struct cpg_address *left_list, size_t left_list_entries,
@@ -294,7 +294,7 @@ static int _init_cluster(void)
 	node_hash = dm_hash_create(100);
 
 	err = cpg_initialize(&cpg_handle,
-			     &cpg_callbacks);
+			     &corosync_cpg_callbacks);
 	if (err != CS_OK) {
 		syslog(LOG_ERR, "Cannot initialise Corosync CPG service: %d",
 		       err);
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 3101069..7c058a8 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -1,7 +1,7 @@
 /******************************************************************************
 *******************************************************************************
 **
-**  Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+**  Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
 **
 *******************************************************************************
 ******************************************************************************/
@@ -41,7 +41,9 @@
 
 #include <openais/saAis.h>
 #include <openais/saLck.h>
-#include <openais/cpg.h>
+
+#include <corosync/corotypes.h>
+#include <corosync/cpg.h>
 
 #include "locking.h"
 #include "lvm-logging.h"
@@ -53,17 +55,18 @@
 /* Timeout value for several openais calls */
 #define TIMEOUT 10
 
-static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+static void openais_cpg_deliver_callback (cpg_handle_t handle,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len);
-static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries);
+				  size_t msg_len);
+static void openais_cpg_confchg_callback(cpg_handle_t handle,
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries);
+
 static void _cluster_closedown(void);
 
 /* Hash list of nodes in the cluster */
@@ -85,9 +88,9 @@ static SaLckHandleT lck_handle;
 static struct cpg_name cpg_group_name;
 
 /* Openais callback structs */
-cpg_callbacks_t cpg_callbacks = {
-	.cpg_deliver_fn =            cpg_deliver_callback,
-	.cpg_confchg_fn =            cpg_confchg_callback,
+cpg_callbacks_t openais_cpg_callbacks = {
+	.cpg_deliver_fn =            openais_cpg_deliver_callback,
+	.cpg_confchg_fn =            openais_cpg_confchg_callback,
 };
 
 struct node_info
@@ -230,12 +233,12 @@ static int add_internal_client(int fd, fd_callback_t callback)
 	return 0;
 }
 
-static void cpg_deliver_callback (cpg_handle_t handle,
-				  struct cpg_name *groupName,
+static void openais_cpg_deliver_callback (cpg_handle_t handle,
+				  const struct cpg_name *groupName,
 				  uint32_t nodeid,
 				  uint32_t pid,
 				  void *msg,
-				  int msg_len)
+				  size_t msg_len)
 {
 	int target_nodeid;
 
@@ -250,11 +253,11 @@ static void cpg_deliver_callback (cpg_handle_t handle,
 					msg_len-OPENAIS_CSID_LEN, (char*)&nodeid);
 }
 
-static void cpg_confchg_callback(cpg_handle_t handle,
-				 struct cpg_name *groupName,
-				 struct cpg_address *member_list, int member_list_entries,
-				 struct cpg_address *left_list, int left_list_entries,
-				 struct cpg_address *joined_list, int joined_list_entries)
+static void openais_cpg_confchg_callback(cpg_handle_t handle,
+				 const struct cpg_name *groupName,
+				 const struct cpg_address *member_list, size_t member_list_entries,
+				 const struct cpg_address *left_list, size_t left_list_entries,
+				 const struct cpg_address *joined_list, size_t joined_list_entries)
 {
 	int i;
 	struct node_info *ninfo;
@@ -330,7 +333,7 @@ static int _init_cluster(void)
 	lock_hash = dm_hash_create(10);
 
 	err = cpg_initialize(&cpg_handle,
-			     &cpg_callbacks);
+			     &openais_cpg_callbacks);
 	if (err != SA_AIS_OK) {
 		syslog(LOG_ERR, "Cannot initialise OpenAIS CPG service: %d",
 		       err);
@@ -342,7 +345,7 @@ static int _init_cluster(void)
 					NULL,
 			      &ver);
 	if (err != SA_AIS_OK) {
-		cpg_initialize(&cpg_handle, &cpg_callbacks);
+		cpg_initialize(&cpg_handle, &openais_cpg_callbacks);
 		syslog(LOG_ERR, "Cannot initialise OpenAIS lock service: %d",
 		       err);
 		DEBUGLOG("Cannot initialise OpenAIS lock service: %d\n\n", err);
-- 
1.5.4.3


