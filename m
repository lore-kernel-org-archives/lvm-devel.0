From: Milan Broz <mbroz@redhat.com>
Date: Fri, 10 Apr 2009 13:27:27 +0200
Subject: [PATCH REPOST] clvmd: Add infrastructure for querying for remote locks.
Message-ID: <49DF2D1F.3080000@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add infrastructure for querying for remote locks.

Current code, when need to ensure that volume is not
active on remote node, it need to try to exclusive
activate volume.

Patch adds simple clvmd command which queries all nodes
for lock for given resource.

The lock type is returned in reply in text.

(But code currently uses CR and EX modes only.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/clvm.h          |    1 +
 daemons/clvmd/clvmd-command.c |   11 +++++++
 daemons/clvmd/clvmd.c         |   53 +++++++++++++++++---------------
 daemons/clvmd/lvm-functions.c |   20 ++++++++++++
 daemons/clvmd/lvm-functions.h |    1 +
 lib/activate/activate.c       |   16 +---------
 lib/locking/cluster_locking.c |   67 ++++++++++++++++++++++++++++++++++++++++-
 lib/locking/locking.c         |   18 +++++++++++
 lib/locking/locking.h         |    2 +
 lib/locking/locking_types.h   |    4 ++-
 10 files changed, 151 insertions(+), 42 deletions(-)

diff --git a/daemons/clvmd/clvm.h b/daemons/clvmd/clvm.h
index 481d644..04ab283 100644
--- a/daemons/clvmd/clvm.h
+++ b/daemons/clvmd/clvm.h
@@ -62,6 +62,7 @@ static const char CLVMD_SOCKNAME[] = "\0clvmd";
 /* Lock/Unlock commands */
 #define CLVMD_CMD_LOCK_LV           50
 #define CLVMD_CMD_LOCK_VG           51
+#define CLVMD_CMD_LOCK_QUERY	    52
 
 /* Misc functions */
 #define CLVMD_CMD_REFRESH	    40
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index dffff21..2266a2b 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -90,6 +90,7 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 	int arglen = msglen - sizeof(struct clvm_header) - strlen(msg->node);
 	int status = 0;
 	char *lockname;
+	const char *locktype;
 	struct utsname nodeinfo;
 	unsigned char lock_cmd;
 	unsigned char lock_flags;
@@ -144,6 +145,14 @@ int do_command(struct local_client *client, struct clvm_header *msg, int msglen,
 		}
 		break;
 
+	case CLVMD_CMD_LOCK_QUERY:
+		lockname = &args[2];
+		if (buflen < 3)
+			return EIO;
+		if ((locktype = do_lock_query(lockname)))
+			*retlen = 1 + snprintf(*buf, buflen, "%s", locktype);
+		break;
+
 	case CLVMD_CMD_REFRESH:
 		do_refresh_cache();
 		break;
@@ -278,6 +287,7 @@ int do_pre_command(struct local_client *client)
 	case CLVMD_CMD_GET_CLUSTERNAME:
 	case CLVMD_CMD_SET_DEBUG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_LOCK_QUERY:
 		break;
 
 	default:
@@ -308,6 +318,7 @@ int do_post_command(struct local_client *client)
 
 	case CLVMD_CMD_LOCK_VG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_LOCK_QUERY:
 		/* Nothing to do here */
 		break;
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index fb812ff..b34d26a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -221,44 +221,47 @@ static const char *decode_cmd(unsigned char cmdl)
 	const char *command;
 
 	switch (cmdl) {
-	case CLVMD_CMD_TEST:		
-		command = "TEST";	
+	case CLVMD_CMD_TEST:
+		command = "TEST";
 		break;
-	case CLVMD_CMD_LOCK_VG:		
-		command = "LOCK_VG";	
+	case CLVMD_CMD_LOCK_VG:
+		command = "LOCK_VG";
 		break;
-	case CLVMD_CMD_LOCK_LV:		
-		command = "LOCK_LV";	
+	case CLVMD_CMD_LOCK_LV:
+		command = "LOCK_LV";
 		break;
-	case CLVMD_CMD_REFRESH:		
-		command = "REFRESH";	
+	case CLVMD_CMD_REFRESH:
+		command = "REFRESH";
 		break;
-	case CLVMD_CMD_SET_DEBUG:	
-		command = "SET_DEBUG";	
+	case CLVMD_CMD_SET_DEBUG:
+		command = "SET_DEBUG";
 		break;
-	case CLVMD_CMD_GET_CLUSTERNAME:	
+	case CLVMD_CMD_GET_CLUSTERNAME:
 		command = "GET_CLUSTERNAME";
 		break;
-	case CLVMD_CMD_VG_BACKUP:	
-		command = "VG_BACKUP";	
+	case CLVMD_CMD_VG_BACKUP:
+		command = "VG_BACKUP";
 		break;
-	case CLVMD_CMD_REPLY:		
-		command = "REPLY";	
+	case CLVMD_CMD_REPLY:
+		command = "REPLY";
 		break;
-	case CLVMD_CMD_VERSION:		
-		command = "VERSION";	
+	case CLVMD_CMD_VERSION:
+		command = "VERSION";
 		break;
-	case CLVMD_CMD_GOAWAY:		
-		command = "GOAWAY";	
+	case CLVMD_CMD_GOAWAY:
+		command = "GOAWAY";
 		break;
-	case CLVMD_CMD_LOCK:		
-		command = "LOCK";	
+	case CLVMD_CMD_LOCK:
+		command = "LOCK";
 		break;
-	case CLVMD_CMD_UNLOCK:		
-		command = "UNLOCK";	
+	case CLVMD_CMD_UNLOCK:
+		command = "UNLOCK";
 		break;
-	default:			
-		command = "unknown";    
+	case CLVMD_CMD_LOCK_QUERY:
+		command = "LOCK_QUERY";
+		break;
+	default:
+		command = "unknown";
 		break;
 	}
 
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index f854001..37fe758 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -434,6 +434,26 @@ static int do_deactivate_lv(char *resource, unsigned char lock_flags)
 	return 0;
 }
 
+const char *do_lock_query(char *resource)
+{
+	int mode;
+	const char *type = NULL;
+
+	mode = get_current_lock(resource);
+	switch (mode) {
+		//case LKM_NLMODE: type = "NL"; break;
+		case LKM_CRMODE: type = "CR"; break;
+		//case LKM_CWMODE: type = "CW"; break;
+		case LKM_PRMODE: type = "PR"; break;
+		case LKM_PWMODE: type = "PW"; break;
+		case LKM_EXMODE: type = "EX"; break;
+	}
+
+	DEBUGLOG("do_lock_query: resource '%s', mode %i (%s)\n", resource, mode, type ?: "?");
+
+	return type;
+}
+
 /* This is the LOCK_LV part that happens on all nodes in the cluster -
    it is responsible for the interaction with device-mapper and LVM */
 int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index 0b6866a..5da104c 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -22,6 +22,7 @@ extern int pre_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 		       char *resource);
 extern int do_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 		      char *resource);
+extern const char *do_lock_query(char *resource);
 extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 7011a09..e994292 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -695,21 +695,7 @@ int lv_is_active(struct logical_volume *lv)
 	if (!vg_is_clustered(lv->vg))
 		return 0;
 
-	/*
-	 * FIXME: Cluster does not report per-node LV activation status.
-	 * Currently the best we can do is try exclusive local activation.
-	 * If that succeeds, we know the LV is not active elsewhere in the
-	 * cluster.
-	 */
-	if (activate_lv_excl(lv->vg->cmd, lv)) {
-		deactivate_lv(lv->vg->cmd, lv);
-		return 0;
-	}
-
-	/*
-	 * Exclusive local activation failed so assume it is active elsewhere.
-	 */
-	return 1;
+	return remote_lock_held(lv->lvid.s);
 }
 
 /*
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 1f0e841..75f2cfe 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -33,6 +33,7 @@
 
 #ifndef CLUSTER_LOCKING_INTERNAL
 int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags);
+int lock_resource_query(const char *resource);
 void locking_end(void);
 int locking_init(int type, struct config_tree *cf, uint32_t *flags);
 #endif
@@ -455,6 +456,69 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 	return _lock_for_cluster(clvmd_cmd, flags, lockname);
 }
 
+static int decode_lock_type(const char *response)
+{
+	if (!response)
+		return LCK_NULL;
+	else if (strcmp(response, "EX"))
+		return LCK_EXCL;
+	else if (strcmp(response, "CR"))
+		return LCK_READ;
+	else if (strcmp(response, "PR"))
+		return LCK_PREAD;
+
+	stack;
+	return 0;
+}
+
+#ifdef CLUSTER_LOCKING_INTERNAL
+static int _lock_resource_query(const char *resource, int *mode)
+#else
+int lock_resource_query(const char *resource, int *mode)
+#endif
+{
+	int i, status, len, num_responses, saved_errno;
+	const char *node = "";
+	char *args;
+	lvm_response_t *response = NULL;
+
+	saved_errno = errno;
+	len = strlen(resource) + 3;
+	args = alloca(len);
+	strcpy(args + 2, resource);
+
+	args[0] = 0;
+	args[1] = LCK_CLUSTER_VG;
+
+	status = _cluster_request(CLVMD_CMD_LOCK_QUERY, node, args, len,
+				  &response, &num_responses);
+	*mode = LCK_NULL;
+	for (i = 0; i < num_responses; i++) {
+		if (response[i].status == EHOSTDOWN)
+			continue;
+
+		if (!response[i].response[0])
+			continue;
+
+		/*
+		 * All nodes should use CR, or exactly one node
+		 * should held EX. (PR is obsolete)
+		 * If two nodes node reports different locks,
+		 * something is broken - just return more important mode.
+		 */
+		if (decode_lock_type(response[i].response) > *mode)
+			*mode = decode_lock_type(response[i].response);
+
+		log_debug("Lock held for %s, node %s : %s", resource,
+			  response[i].node, response[i].response);
+	}
+
+	_cluster_free_request(response, num_responses);
+	errno = saved_errno;
+
+	return status;
+}
+
 #ifdef CLUSTER_LOCKING_INTERNAL
 static void _locking_end(void)
 #else
@@ -485,6 +549,7 @@ void reset_locking(void)
 int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd)
 {
 	locking->lock_resource = _lock_resource;
+	locking->lock_resource_query = _lock_resource_query;
 	locking->fin_locking = _locking_end;
 	locking->reset_locking = _reset_locking;
 	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED;
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index ad93ddd..3e4ec37 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -474,3 +474,21 @@ int locking_is_clustered(void)
 	return (_locking.flags & LCK_CLUSTERED) ? 1 : 0;
 }
 
+int remote_lock_held(const char *vol)
+{
+	int mode = LCK_NULL;
+
+	if (!locking_is_clustered())
+		return 0;
+
+	/*
+	 * If an error occured, expect that volume is active
+	 */
+	if (!_locking.lock_resource_query ||
+	    !_locking.lock_resource_query(vol, &mode)) {
+		stack;
+		return 1;
+	}
+
+	return mode == LCK_NULL ? 0 : 1;
+}
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index ee7f5a1..57738a6 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -25,6 +25,8 @@ void reset_locking(void);
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
 
+int remote_lock_held(const char *vol);
+
 /*
  * LCK_VG:
  *   Lock/unlock on-disk volume group data.
diff --git a/lib/locking/locking_types.h b/lib/locking/locking_types.h
index f783629..425a772 100644
--- a/lib/locking/locking_types.h
+++ b/lib/locking/locking_types.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,6 +18,7 @@
 
 typedef int (*lock_resource_fn) (struct cmd_context * cmd, const char *resource,
 				 uint32_t flags);
+typedef int (*lock_resource_query_fn) (const char *resource, int *mode);
 
 typedef void (*fin_lock_fn) (void);
 typedef void (*reset_lock_fn) (void);
@@ -28,6 +29,7 @@ typedef void (*reset_lock_fn) (void);
 struct locking_type {
 	uint32_t flags;
 	lock_resource_fn lock_resource;
+	lock_resource_query_fn lock_resource_query;
 
 	reset_lock_fn reset_locking;
 	fin_lock_fn fin_locking;



