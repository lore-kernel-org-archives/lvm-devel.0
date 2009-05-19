From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 May 2009 10:39:05 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvm.h daemons/ ...
Message-ID: <20090519103905.25884.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-19 10:39:01

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvm.h clvmd-command.c clvmd.c lvm-functions.c 
	                 lvm-functions.h 
	lib/activate   : activate.c 
	lib/locking    : cluster_locking.c locking.c locking.h 
	                 locking_types.h 

Log message:
	Add infrastructure for queriying for remote locks.
	
	Current code, when need to ensure that volume is not
	active on remote node, it need to try to exclusive
	activate volume.
	
	Patch adds simple clvmd command which queries all nodes
	for lock for given resource.
	
	The lock type is returned in reply in text.
	
	(But code currently uses CR and EX modes only.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1115&r2=1.1116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2009/05/19 10:25:16	1.1115
+++ LVM2/WHATS_NEW	2009/05/19 10:38:58	1.1116
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Introduce CLVMD_CMD_LOCK_QUERY command for clvmd.
   Use lvconvert --repair in dmeventd mirror DSO.
   Fix pvmove to revert operation if temporary mirror creation fails.
   Fix metadata export for VG with missing PVs.
--- LVM2/daemons/clvmd/clvm.h	2007/12/04 15:39:26	1.6
+++ LVM2/daemons/clvmd/clvm.h	2009/05/19 10:38:58	1.7
@@ -62,6 +62,7 @@
 /* Lock/Unlock commands */
 #define CLVMD_CMD_LOCK_LV           50
 #define CLVMD_CMD_LOCK_VG           51
+#define CLVMD_CMD_LOCK_QUERY	    52
 
 /* Misc functions */
 #define CLVMD_CMD_REFRESH	    40
--- LVM2/daemons/clvmd/clvmd-command.c	2009/04/22 09:39:45	1.27
+++ LVM2/daemons/clvmd/clvmd-command.c	2009/05/19 10:39:00	1.28
@@ -90,6 +90,7 @@
 	int arglen = msglen - sizeof(struct clvm_header) - strlen(msg->node);
 	int status = 0;
 	char *lockname;
+	const char *locktype;
 	struct utsname nodeinfo;
 	unsigned char lock_cmd;
 	unsigned char lock_flags;
@@ -144,6 +145,14 @@
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
@@ -278,6 +287,7 @@
 	case CLVMD_CMD_GET_CLUSTERNAME:
 	case CLVMD_CMD_SET_DEBUG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_LOCK_QUERY:
 		break;
 
 	default:
@@ -308,6 +318,7 @@
 
 	case CLVMD_CMD_LOCK_VG:
 	case CLVMD_CMD_VG_BACKUP:
+	case CLVMD_CMD_LOCK_QUERY:
 		/* Nothing to do here */
 		break;
 
--- LVM2/daemons/clvmd/clvmd.c	2009/04/22 10:38:16	1.57
+++ LVM2/daemons/clvmd/clvmd.c	2009/05/19 10:39:00	1.58
@@ -257,6 +257,9 @@
 	case CLVMD_CMD_UNLOCK:
 		command = "UNLOCK";
 		break;
+	case CLVMD_CMD_LOCK_QUERY:
+		command = "LOCK_QUERY";
+		break;
 	default:
 		command = "unknown";
 		break;
--- LVM2/daemons/clvmd/lvm-functions.c	2009/04/21 13:11:28	1.60
+++ LVM2/daemons/clvmd/lvm-functions.c	2009/05/19 10:39:00	1.61
@@ -434,6 +434,26 @@
 	return 0;
 }
 
+const char *do_lock_query(char *resource)
+{
+	int mode;
+	const char *type = NULL;
+
+	mode = get_current_lock(resource);
+	switch (mode) {
+		case LKM_NLMODE: type = "NL"; break;
+		case LKM_CRMODE: type = "CR"; break;
+		case LKM_CWMODE: type = "CW"; break;
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
--- LVM2/daemons/clvmd/lvm-functions.h	2009/04/21 13:11:28	1.9
+++ LVM2/daemons/clvmd/lvm-functions.h	2009/05/19 10:39:00	1.10
@@ -22,6 +22,7 @@
 		       char *resource);
 extern int do_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 		      char *resource);
+extern const char *do_lock_query(char *resource);
 extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
--- LVM2/lib/activate/activate.c	2009/05/13 21:27:43	1.147
+++ LVM2/lib/activate/activate.c	2009/05/19 10:39:00	1.148
@@ -695,21 +695,7 @@
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
--- LVM2/lib/locking/cluster_locking.c	2009/04/22 09:39:46	1.33
+++ LVM2/lib/locking/cluster_locking.c	2009/05/19 10:39:00	1.34
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
+int lock_resource_query(const char *resource, int *mode);
 void locking_end(void);
 int locking_init(int type, struct config_tree *cf, uint32_t *flags);
 #endif
@@ -455,6 +456,69 @@
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
@@ -485,6 +549,7 @@
 int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd)
 {
 	locking->lock_resource = _lock_resource;
+	locking->lock_resource_query = _lock_resource_query;
 	locking->fin_locking = _locking_end;
 	locking->reset_locking = _reset_locking;
 	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED;
--- LVM2/lib/locking/locking.c	2009/05/13 13:02:55	1.57
+++ LVM2/lib/locking/locking.c	2009/05/19 10:39:00	1.58
@@ -482,3 +482,21 @@
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
--- LVM2/lib/locking/locking.h	2009/04/22 09:39:46	1.45
+++ LVM2/lib/locking/locking.h	2009/05/19 10:39:00	1.46
@@ -25,6 +25,8 @@
 int vg_write_lock_held(void);
 int locking_is_clustered(void);
 
+int remote_lock_held(const char *vol);
+
 /*
  * LCK_VG:
  *   Lock/unlock on-disk volume group data.
--- LVM2/lib/locking/locking_types.h	2007/08/22 14:38:17	1.15
+++ LVM2/lib/locking/locking_types.h	2009/05/19 10:39:00	1.16
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
@@ -28,6 +29,7 @@
 struct locking_type {
 	uint32_t flags;
 	lock_resource_fn lock_resource;
+	lock_resource_query_fn lock_resource_query;
 
 	reset_lock_fn reset_locking;
 	fin_lock_fn fin_locking;


