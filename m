From: Milan Broz <mbroz@redhat.com>
Date: Tue,  9 Aug 2011 18:39:45 +0200
Subject: [PATCH] Remove GULM support completely.
Message-ID: <1312907985-23182-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This cluster locking is not used for years and is completely obsoleted.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 configure.in                  |   50 +--
 daemons/clvmd/Makefile.in     |   10 -
 daemons/clvmd/clvmd-comms.h   |    7 -
 daemons/clvmd/clvmd-gulm.c    | 1010 -----------------------------------------
 daemons/clvmd/clvmd-gulm.h    |    9 -
 daemons/clvmd/clvmd.c         |   29 +-
 daemons/clvmd/lvm-functions.c |   46 +--
 daemons/clvmd/lvm-functions.h |    2 +-
 daemons/clvmd/tcp-comms.c     |  502 --------------------
 daemons/clvmd/tcp-comms.h     |   13 -
 lib/misc/configure.h.in       |    6 -
 11 files changed, 8 insertions(+), 1676 deletions(-)
 delete mode 100644 daemons/clvmd/clvmd-gulm.c
 delete mode 100644 daemons/clvmd/clvmd-gulm.h
 delete mode 100644 daemons/clvmd/tcp-comms.c
 delete mode 100644 daemons/clvmd/tcp-comms.h

diff --git a/configure.in b/configure.in
index 24f1ec4..5b52c4d 100644
--- a/configure.in
+++ b/configure.in
@@ -423,7 +423,6 @@ AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
   [  --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
-                           * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
                            * singlenode            (localhost only)
@@ -449,15 +448,10 @@ fi
 dnl -- Express clvmd init script Required-Start / Required-Stop
 CLVMD_CMANAGERS=""
 dnl -- On RHEL4/RHEL5, qdiskd is started from a separate init script.
-dnl -- Enable if we are build for either cman or gulm.
+dnl -- Enable if we are build for cman.
 CLVMD_NEEDS_QDISKD=no
 
 dnl -- define build types
-if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
-	BUILDGULM=yes
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
-	CLVMD_NEEDS_QDISKD=yes
-fi
 if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
 	BUILDCMAN=yes
 	CLVMD_CMANAGERS="$CLVMD_CMANAGERS cman"
@@ -475,14 +469,6 @@ if test x$CLVMD_NEEDS_QDISKD != xno; then
 	CLVMD_CMANAGERS="$CLVMD_CMANAGERS qdiskd"
 fi
 
-dnl -- sanity check around user selection
-if test x$BUILDGULM = xyes; then
-	if test x$BUILDCOROSYNC = xyes || \
-	   test x$BUILDOPENAIS = xyes; then
-		AC_MSG_ERROR([requested clvmd configuration is not valid])
-	fi
-fi
-
 dnl -- define a soft bailout if we are autodetecting
 soft_bailout() {
 	NOTFOUND=1
@@ -494,10 +480,9 @@ hard_bailout() {
 
 dnl -- if clvmd=all then set soft_bailout (we don't want to error)
 dnl -- and set all builds to yes. We need to do this here
-dnl -- to skip the gulm + openais|corosync sanity check above.
+dnl -- to skip the openais|corosync sanity check above.
 if test x$CLVMD = xall; then
 	bailout=soft_bailout
-	BUILDGULM=yes
 	BUILDCMAN=yes
 	BUILDCOROSYNC=yes
 	BUILDOPENAIS=yes
@@ -519,28 +504,6 @@ check_lib_no_libs() {
 	LIBS=$ac_check_lib_save_LIBS
 }
 
-dnl -- Look for gulm libraries if required.
-if test x$BUILDGULM = xyes; then
-	PKG_CHECK_MODULES(CCS, libccs, [HAVE_CCS=yes],
-		[NOTFOUND=0
-		AC_CHECK_HEADERS(ccs.h,,$bailout)
-		check_lib_no_libs ccs ccs_connect
-		if test $NOTFOUND = 0; then
-			AC_MSG_RESULT([no pkg for libccs, using -lccs])
-			CCS_LIBS="-lccs"
-			HAVE_CCS=yes
-		fi])
-	PKG_CHECK_MODULES(GULM, libgulm, [HAVE_GULM=yes],
-		[NOTFOUND=0
-		AC_CHECK_HEADERS(libgulm.h,,$bailout)
-		check_lib_no_libs gulm lg_core_login
-		if test $NOTFOUND = 0; then
-			AC_MSG_RESULT([no pkg for libgulm, using -lgulm])
-			GULM_LIBS="-lgulm"
-			HAVE_GULM=yes
-		fi])
-fi
-
 dnl -- Look for cman libraries if required.
 if test x$BUILDCMAN = xyes; then
 	PKG_CHECK_MODULES(CMAN, libcman, [HAVE_CMAN=yes],
@@ -633,13 +596,6 @@ if test x$CLVMD = xall; then
 	CLVMD=none
 	CLVMD_CMANAGERS=""
 	CLVMD_NEEDS_QDISKD=no
-	if test x$HAVE_CCS = xyes && \
-	   test x$HAVE_GULM = xyes; then
-		AC_MSG_RESULT([Enabling clvmd gulm cluster manager])
-		CLVMD="$CLVMD,gulm"
-		CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
-		CLVMD_NEEDS_QDISKD=yes
-	fi
 	if test x$HAVE_CMAN = xyes && \
 	   test x$HAVE_DLM = xyes; then
 		AC_MSG_RESULT([Enabling clvmd cman cluster manager])
@@ -1346,8 +1302,6 @@ AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GULM_CFLAGS)
-AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(INTL)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index ee19e6c..91fd273 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -25,8 +25,6 @@ CPG_LIBS = @CPG_LIBS@
 CPG_CFLAGS = @CPG_CFLAGS@
 DLM_LIBS = @DLM_LIBS@
 DLM_CFLAGS = @DLM_CFLAGS@
-GULM_LIBS = @GULM_LIBS@
-GULM_CFLAGS = @GULM_CFLAGS@
 QUORUM_LIBS = @QUORUM_LIBS@
 QUORUM_CFLAGS = @QUORUM_CFLAGS@
 SALCK_LIBS = @SALCK_LIBS@
@@ -42,13 +40,6 @@ ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-ifneq (,$(findstring gulm,, "@CLVMD@,"))
-	SOURCES += clvmd-gulm.c tcp-comms.c
-	LMLIBS += $(CCS_LIBS) $(GULM_LIBS)
-	CFLAGS += $(CCS_CFLAGS) $(GULM_CFLAGS)
-	DEFS += -DUSE_GULM
-endif
-
 ifneq (,$(findstring cman,, "@CLVMD@,"))
 	SOURCES += clvmd-cman.c
 	LMLIBS += $(CMAN_LIBS) $(CONFDB_LIBS) $(DLM_LIBS)
@@ -76,7 +67,6 @@ ifneq (,$(findstring singlenode,, &quot;@CLVMD@,&quot;))
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-	SOURCES += clvmd-gulm.c tcp-comms.c
 	SOURCES += clvmd-cman.c
 	SOURCES += clvmd-openais.c
 	SOURCES += clvmd-corosync.c
diff --git a/daemons/clvmd/clvmd-comms.h b/daemons/clvmd/clvmd-comms.h
index fbcfe8b..500bd57 100644
--- a/daemons/clvmd/clvmd-comms.h
+++ b/daemons/clvmd/clvmd-comms.h
@@ -54,13 +54,6 @@ struct cluster_ops {
 
 };
 
-#ifdef USE_GULM
-#  include "tcp-comms.h"
-struct cluster_ops *init_gulm_cluster(void);
-#define MAX_CSID_LEN 			GULM_MAX_CSID_LEN
-#define MAX_CLUSTER_MEMBER_NAME_LEN	GULM_MAX_CLUSTER_MEMBER_NAME_LEN
-#endif
-
 #ifdef USE_CMAN
 #  include <netinet/in.h>
 #  include "libcman.h"
diff --git a/daemons/clvmd/clvmd-gulm.c b/daemons/clvmd/clvmd-gulm.c
deleted file mode 100644
index 3561004..0000000
diff --git a/daemons/clvmd/clvmd-gulm.h b/daemons/clvmd/clvmd-gulm.h
deleted file mode 100644
index 9416f5c..0000000
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 703268f..07883ea 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -78,7 +78,6 @@ struct lvm_thread_cmd {
 };
 
 struct lvm_startup_params {
-	int using_gulm;
 	char **argv;
 };
 
@@ -101,7 +100,7 @@ static int child_pipe[2];
 #define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
-typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
+typedef enum {IF_AUTO, IF_CMAN, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
 
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
@@ -166,9 +165,6 @@ static void usage(const char *prog, FILE *file)
 #ifdef USE_OPENAIS
 		"openais "
 #endif
-#ifdef USE_GULM
-		"gulm "
-#endif
 #ifdef USE_SINGLENODE
 		"singlenode "
 #endif
@@ -342,7 +338,6 @@ int main(int argc, char *argv[])
 	int start_timeout = 0;
 	if_type_t cluster_iface = IF_AUTO;
 	sigset_t ss;
-	int using_gulm = 0;
 	int debug_opt = 0;
 	debug_t debug_arg = DEBUG_OFF;
 	int clusterwide_opt = 0;
@@ -473,7 +468,7 @@ int main(int argc, char *argv[])
 
 	/* Set up signal handlers, USR1 is for cluster change notifications (in cman)
 	   USR2 causes child threads to exit.
-	   HUP causes gulm version to re-read nodes list from CCS.
+	   HUP causes to re-read nodes list from CCS.
 	   PIPE should be ignored */
 	signal(SIGUSR2, sigusr2_handler);
 	signal(SIGHUP,  sighup_handler);
@@ -505,16 +500,6 @@ int main(int argc, char *argv[])
 		syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to CMAN");
 	}
 #endif
-#ifdef USE_GULM
-	if (!clops)
-		if ((cluster_iface == IF_AUTO || cluster_iface == IF_GULM) && (clops = init_gulm_cluster())) {
-			max_csid_len = GULM_MAX_CSID_LEN;
-			max_cluster_message = GULM_MAX_CLUSTER_MESSAGE;
-			max_cluster_member_name_len = GULM_MAX_CLUSTER_MEMBER_NAME_LEN;
-			using_gulm = 1;
-			syslog(LOG_NOTICE, "Cluster LVM daemon started - connected to GULM");
-		}
-#endif
 #ifdef USE_COROSYNC
 	if (!clops)
 		if (((cluster_iface == IF_AUTO || cluster_iface == IF_COROSYNC) && (clops = init_corosync_cluster()))) {
@@ -580,14 +565,10 @@ int main(int argc, char *argv[])
 
 	/* Don't let anyone else to do work until we are started */
 	pthread_mutex_lock(&lvm_start_mutex);
-	lvm_params.using_gulm = using_gulm;
 	lvm_params.argv = argv;
 	pthread_create(&lvm_thread, NULL, lvm_thread_fn, &lvm_params);
 
 	/* Tell the rest of the cluster our version number */
-	/* CMAN can do this immediately, gulm needs to wait until
-	   the core initialisation has finished and the node list
-	   has been gathered */
 	if (clops->cluster_init_completed)
 		clops->cluster_init_completed();
 
@@ -625,7 +606,7 @@ int main(int argc, char *argv[])
 	return 0;
 }
 
-/* Called when the GuLM cluster layer has completed initialisation.
+/* Called when the cluster layer has completed initialisation.
    We send the version message */
 void clvmd_cluster_init_completed(void)
 {
@@ -1965,7 +1946,7 @@ static void *lvm_thread_fn(void *arg)
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_clvm(lvm_params->using_gulm, lvm_params->argv);
+	init_clvm(lvm_params->argv);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
@@ -2222,8 +2203,6 @@ static if_type_t parse_cluster_interface(char *ifname)
 		iface = IF_AUTO;
 	if (!strcmp(ifname, "cman"))
 		iface = IF_CMAN;
-	if (!strcmp(ifname, "gulm"))
-		iface = IF_GULM;
 	if (!strcmp(ifname, "openais"))
 		iface = IF_OPENAIS;
 	if (!strcmp(ifname, "corosync"))
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c10ce9d..d2c89d9 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -650,46 +650,6 @@ int do_refresh_cache(void)
 	return 0;
 }
 
-
-/* Only called at gulm startup. Drop any leftover VG or P_orphan locks
-   that might be hanging around if we died for any reason
-*/
-static void drop_vg_locks(void)
-{
-	char vg[128];
-	char line[255];
-	FILE *vgs =
-	    popen
-	    (LVM_PATH " pvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_name", "r");
-
-	sync_unlock("P_" VG_ORPHANS, LCK_EXCL);
-	sync_unlock("P_" VG_GLOBAL, LCK_EXCL);
-
-	if (!vgs)
-		return;
-
-	while (fgets(line, sizeof(line), vgs)) {
-		char *vgend;
-		char *vgstart;
-
-		if (line[strlen(line)-1] == '\n')
-			line[strlen(line)-1] = '\0';
-
-		vgstart = line + strspn(line, " ");
-		vgend = vgstart + strcspn(vgstart, " ");
-		*vgend = '\0';
-
-		if (strncmp(vgstart, "WARNING:", 8) == 0)
-			continue;
-
-		sprintf(vg, "V_%s", vgstart);
-		sync_unlock(vg, LCK_EXCL);
-
-	}
-	if (fclose(vgs))
-		DEBUGLOG("vgs fclose failed: %s\n", strerror(errno));
-}
-
 /*
  * Handle VG lock - drop metadata or update lvmcache state
  */
@@ -920,7 +880,7 @@ void lvm_do_fs_unlock(void)
 }
 
 /* Called to initialise the LVM context of the daemon */
-int init_clvm(int using_gulm, char **argv)
+int init_clvm(char **argv)
 {
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
@@ -942,10 +902,6 @@ int init_clvm(int using_gulm, char **argv)
 	check_config();
 	init_ignore_suspended_devices(1);
 
-	/* Remove any non-LV locks that may have been left around */
-	if (using_gulm)
-		drop_vg_locks();
-
 	get_initial_state(argv);
 
 	/* Trap log messages so we can pass them back to the user */
diff --git a/daemons/clvmd/lvm-functions.h b/daemons/clvmd/lvm-functions.h
index a132f4a..f9c43b7 100644
--- a/daemons/clvmd/lvm-functions.h
+++ b/daemons/clvmd/lvm-functions.h
@@ -27,7 +27,7 @@ extern int post_lock_lv(unsigned char lock_cmd, unsigned char lock_flags,
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_clvm(int using_gulm, char **argv);
+extern int init_clvm(char **argv);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
diff --git a/daemons/clvmd/tcp-comms.c b/daemons/clvmd/tcp-comms.c
deleted file mode 100644
index 5f86556..0000000
diff --git a/daemons/clvmd/tcp-comms.h b/daemons/clvmd/tcp-comms.h
deleted file mode 100644
index 9260e12..0000000
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 65f6332..16e290a 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -84,9 +84,6 @@
 /* Define to 1 if canonicalize_file_name is available. */
 #undef HAVE_CANONICALIZE_FILE_NAME
 
-/* Define to 1 if you have the <ccs.h> header file. */
-#undef HAVE_CCS_H
-
 /* Define to 1 if your system has a working `chown' function. */
 #undef HAVE_CHOWN
 
@@ -159,9 +156,6 @@
 /* Define to 1 if you have the <libgen.h> header file. */
 #undef HAVE_LIBGEN_H
 
-/* Define to 1 if you have the <libgulm.h> header file. */
-#undef HAVE_LIBGULM_H
-
 /* Define to 1 if you have the <libintl.h> header file. */
 #undef HAVE_LIBINTL_H
 
-- 
1.7.6


