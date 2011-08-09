From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 Aug 2011 11:44:58 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c ...
Message-ID: <20110809114458.22396.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-09 11:44:57

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c external_locking.c 
	                 file_locking.c locking.c locking_types.h 
	                 no_locking.c 
	lib/log        : log.h 

Log message:
	Suppress low-level locking errors and warnings while using --sysinit.
	
	Today, we use "suppress_messages" flag (set internally in init_locking fn based
	on 'ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES")'.
	This way, we can suppress high level messages like "File-based locking
	initialisation failed" or "Internal cluster locking initialisation failed".
	
	However, each locking has its own sequence of initialization steps and these
	could log some errors as well. It's quite misleading for the user to see such
	errors and warnings if the "--sysinit" is used (and so the ignorelockingfailure
	&& LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES environment variable). Errors and
	warnings from these intermediary steps should be suppressed as well if requested.
	
	This patch propagates the "suppress_messages" flag deeper into locking init
	functions. I've also added these flags for other locking types for consistency,
	though it's not actually used for no_locking and readonly_locking.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2052&r2=1.2053
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/external_locking.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/WHATS_NEW	2011/08/04 15:18:10	1.2052
+++ LVM2/WHATS_NEW	2011/08/09 11:44:57	1.2053
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Suppress low-level locking errors and warnings while using --sysinit.
   Remove unused inconsistent_seqno variable in _vg_read().
   Remove meaningless const type qualifiers on cast type.
   Fix memory leak in dmsetup _message() memory allocation error path.
--- LVM2/lib/locking/cluster_locking.c	2011/06/01 21:16:56	1.56
+++ LVM2/lib/locking/cluster_locking.c	2011/08/09 11:44:57	1.57
@@ -62,14 +62,15 @@
 /* FIXME Install SIGPIPE handler? */
 
 /* Open connection to the Cluster Manager daemon */
-static int _open_local_sock(void)
+static int _open_local_sock(int suppress_messages)
 {
 	int local_socket;
 	struct sockaddr_un sockaddr;
 
 	/* Open local socket */
 	if ((local_socket = socket(PF_UNIX, SOCK_STREAM, 0)) < 0) {
-		log_error("Local socket creation failed: %s", strerror(errno));
+		log_error_suppress(suppress_messages, "Local socket "
+				   "creation failed: %s", strerror(errno));
 		return -1;
 	}
 
@@ -82,8 +83,8 @@
 		    sizeof(sockaddr))) {
 		int saved_errno = errno;
 
-		log_error("connect() failed on local socket: %s",
-			  strerror(errno));
+		log_error_suppress(suppress_messages, "connect() failed "
+				   "on local socket: %s", strerror(errno));
 		if (close(local_socket))
 			stack;
 
@@ -212,7 +213,7 @@
 	*num = 0;
 
 	if (_clvmd_sock == -1)
-		_clvmd_sock = _open_local_sock();
+		_clvmd_sock = _open_local_sock(0);
 
 	if (_clvmd_sock == -1)
 		return 0;
@@ -583,13 +584,14 @@
 	if (close(_clvmd_sock))
 		stack;
 
-	_clvmd_sock = _open_local_sock();
+	_clvmd_sock = _open_local_sock(0);
 	if (_clvmd_sock == -1)
 		stack;
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
-int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd)
+int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd,
+			 int suppress_messages)
 {
 	locking->lock_resource = _lock_resource;
 	locking->query_resource = _query_resource;
@@ -597,7 +599,7 @@
 	locking->reset_locking = _reset_locking;
 	locking->flags = LCK_PRE_MEMLOCK | LCK_CLUSTERED;
 
-	_clvmd_sock = _open_local_sock();
+	_clvmd_sock = _open_local_sock(suppress_messages);
 	if (_clvmd_sock == -1)
 		return 0;
 
@@ -606,7 +608,7 @@
 #else
 int locking_init(int type, struct config_tree *cf, uint32_t *flags)
 {
-	_clvmd_sock = _open_local_sock();
+	_clvmd_sock = _open_local_sock(0);
 	if (_clvmd_sock == -1)
 		return 0;
 
--- LVM2/lib/locking/external_locking.c	2011/02/04 19:18:17	1.18
+++ LVM2/lib/locking/external_locking.c	2011/08/09 11:44:57	1.19
@@ -65,12 +65,13 @@
 		_reset_fn();
 }
 
-int init_external_locking(struct locking_type *locking, struct cmd_context *cmd)
+int init_external_locking(struct locking_type *locking, struct cmd_context *cmd,
+			  int suppress_messages)
 {
 	const char *libname;
 
 	if (_locking_lib) {
-		log_error("External locking already initialised");
+		log_error_suppress(suppress_messages, "External locking already initialised");
 		return 1;
 	}
 
@@ -90,16 +91,16 @@
 	    !(_lock_fn = dlsym(_locking_lib, "lock_resource")) ||
 	    !(_reset_fn = dlsym(_locking_lib, "reset_locking")) ||
 	    !(_end_fn = dlsym(_locking_lib, "locking_end"))) {
-		log_error("Shared library %s does not contain locking "
-			  "functions", libname);
+		log_error_suppress(suppress_messages, "Shared library %s does "
+				   "not contain locking functions", libname);
 		dlclose(_locking_lib);
 		_locking_lib = NULL;
 		return 0;
 	}
 
 	if (!(_lock_query_fn = dlsym(_locking_lib, "query_resource")))
-		log_warn("WARNING: %s: _query_resource() missing: "
-			 "Using inferior activation method.", libname);
+		log_warn_suppress(suppress_messages, "WARNING: %s: _query_resource() "
+				  "missing: Using inferior activation method.", libname);
 
 	log_verbose("Loaded external locking library %s", libname);
 	return _init_fn(2, cmd->cft, &locking->flags);
--- LVM2/lib/locking/file_locking.c	2011/04/08 14:13:08	1.59
+++ LVM2/lib/locking/file_locking.c	2011/08/09 11:44:57	1.60
@@ -332,7 +332,8 @@
 	return 1;
 }
 
-int init_file_locking(struct locking_type *locking, struct cmd_context *cmd)
+int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
+		      int suppress_messages)
 {
 	int r;
 
@@ -364,12 +365,14 @@
 	dm_list_init(&_lock_list);
 
 	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
-		log_sys_error("sigfillset", "init_file_locking");
+		log_sys_error_suppress(suppress_messages, "sigfillset",
+				       "init_file_locking");
 		return 0;
 	}
 
 	if (sigdelset(&_intsigset, SIGINT)) {
-		log_sys_error("sigdelset", "init_file_locking");
+		log_sys_error_suppress(suppress_messages, "sigdelset",
+				       "init_file_locking");
 		return 0;
 	}
 
--- LVM2/lib/locking/locking.c	2011/06/11 00:03:07	1.95
+++ LVM2/lib/locking/locking.c	2011/08/09 11:44:57	1.96
@@ -232,7 +232,7 @@
 
 	switch (type) {
 	case 0:
-		init_no_locking(&_locking, cmd);
+		init_no_locking(&_locking, cmd, suppress_messages);
 		log_warn("WARNING: Locking disabled. Be careful! "
 			  "This could corrupt your metadata.");
 		return 1;
@@ -241,7 +241,7 @@
 		log_very_verbose("%sFile-based locking selected.",
 				 _blocking_supported ? "" : "Non-blocking ");
 
-		if (!init_file_locking(&_locking, cmd)) {
+		if (!init_file_locking(&_locking, cmd, suppress_messages)) {
 			log_error_suppress(suppress_messages,
 					   "File-based locking initialisation failed.");
 			break;
@@ -252,13 +252,13 @@
 	case 2:
 		if (!is_static()) {
 			log_very_verbose("External locking selected.");
-			if (init_external_locking(&_locking, cmd))
+			if (init_external_locking(&_locking, cmd, suppress_messages))
 				return 1;
 		}
 		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
 			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
 						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))) {
-			log_error("External locking initialisation failed.");
+			log_error_suppress(suppress_messages, "External locking initialisation failed.");
 			break;
 		}
 #endif
@@ -269,7 +269,7 @@
 
 	case 3:
 		log_very_verbose("Cluster locking selected.");
-		if (!init_cluster_locking(&_locking, cmd)) {
+		if (!init_cluster_locking(&_locking, cmd, suppress_messages)) {
 			log_error_suppress(suppress_messages,
 					   "Internal cluster locking initialisation failed.");
 			break;
@@ -280,7 +280,7 @@
 	case 4:
 		log_verbose("Read-only locking selected. "
 			    "Only read operations permitted.");
-		if (!init_readonly_locking(&_locking, cmd))
+		if (!init_readonly_locking(&_locking, cmd, suppress_messages))
 			break;
 		return 1;
 
@@ -297,7 +297,7 @@
 		log_warn_suppress(suppress_messages,
 				  "Volume Groups with the clustered attribute will "
 				  "be inaccessible.");
-		if (init_file_locking(&_locking, cmd))
+		if (init_file_locking(&_locking, cmd, suppress_messages))
 			return 1;
 		else
 			log_error_suppress(suppress_messages,
@@ -308,7 +308,7 @@
 		return 0;
 
 	log_verbose("Locking disabled - only read operations permitted.");
-	init_readonly_locking(&_locking, cmd);
+	init_readonly_locking(&_locking, cmd, suppress_messages);
 
 	return 1;
 }
--- LVM2/lib/locking/locking_types.h	2009/07/15 05:57:11	1.19
+++ LVM2/lib/locking/locking_types.h	2011/08/09 11:44:57	1.20
@@ -38,12 +38,17 @@
 /*
  * Locking types
  */
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_no_locking(struct locking_type *locking, struct cmd_context *cmd,
+		    int suppress_messages);
 
-int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd,
+			  int suppress_messages);
 
-int init_file_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
+		      int suppress_messages);
 
-int init_external_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_external_locking(struct locking_type *locking, struct cmd_context *cmd,
+			  int suppress_messages);
 
-int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_cluster_locking(struct locking_type *locking, struct cmd_context *cmd,
+			 int suppress_messages);
--- LVM2/lib/locking/no_locking.c	2011/02/18 00:36:05	1.28
+++ LVM2/lib/locking/no_locking.c	2011/08/09 11:44:57	1.29
@@ -81,7 +81,8 @@
 	return _no_lock_resource(cmd, resource, flags);
 }
 
-int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)))
+int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
+		    int suppress_messages)
 {
 	locking->lock_resource = _no_lock_resource;
 	locking->reset_locking = _no_reset_locking;
@@ -91,7 +92,8 @@
 	return 1;
 }
 
-int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)))
+int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd __attribute__((unused)),
+			  int suppress_messages)
 {
 	locking->lock_resource = _readonly_lock_resource;
 	locking->reset_locking = _no_reset_locking;
--- LVM2/lib/log/log.h	2010/06/21 15:56:59	1.50
+++ LVM2/lib/log/log.h	2011/08/09 11:44:57	1.51
@@ -76,6 +76,8 @@
 /* System call equivalents */
 #define log_sys_error(x, y) \
 		log_err("%s: %s failed: %s", y, x, strerror(errno))
+#define log_sys_error_suppress(s, x, y) \
+		log_err_suppress(s, "%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_very_verbose(x, y) \
 		log_info("%s: %s failed: %s", y, x, strerror(errno))
 #define log_sys_debug(x, y) \


