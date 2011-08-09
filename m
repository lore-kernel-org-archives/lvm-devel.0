From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Aug 2011 18:11:03 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in daemons/clvmd/ ...
Message-ID: <20110809181103.13403.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-09 18:11:01

Modified files:
	.              : WHATS_NEW configure.in 
	daemons/clvmd  : Makefile.in clvmd-comms.h clvmd.c 
	                 lvm-functions.c lvm-functions.h 
	man            : clvmd.8.in 
Removed files:
	daemons/clvmd  : clvmd-gulm.c clvmd-gulm.h tcp-comms.c 
	                 tcp-comms.h 

Log message:
	Remove obsoleted GULM clvmd cluster locking support.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2053&r2=1.2054
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.31&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.h.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.22&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.h.diff?cvsroot=lvm2&r1=1.6&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2011/08/09 11:44:57	1.2053
+++ LVM2/WHATS_NEW	2011/08/09 18:11:00	1.2054
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Remove obsoleted GULM clvmd cluster locking support.
   Suppress low-level locking errors and warnings while using --sysinit.
   Remove unused inconsistent_seqno variable in _vg_read().
   Remove meaningless const type qualifiers on cast type.
--- LVM2/configure.in	2011/08/09 17:56:47	1.165
+++ LVM2/configure.in	2011/08/09 18:11:00	1.166
@@ -423,7 +423,6 @@
 AC_ARG_WITH(clvmd,
   [  --with-clvmd=TYPE       build cluster LVM Daemon
                           The following cluster manager combinations are valid:
-                           * cman,gulm             (RHEL4 or equivalent)
                            * cman                  (RHEL5 or equivalent)
                            * cman,corosync,openais (or selection of them)
                            * singlenode            (localhost only)
@@ -449,14 +448,12 @@
 dnl -- Express clvmd init script Required-Start / Required-Stop
 CLVMD_CMANAGERS=""
 dnl -- On RHEL4/RHEL5, qdiskd is started from a separate init script.
-dnl -- Enable if we are build for either cman or gulm.
+dnl -- Enable if we are build for cman.
 CLVMD_NEEDS_QDISKD=no
 
 dnl -- define build types
 if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
-	BUILDGULM=yes
-	CLVMD_CMANAGERS="$CLVMD_CMANAGERS lock_gulmd"
-	CLVMD_NEEDS_QDISKD=yes
+	AC_MSG_ERROR([Since version 2.02.87 GULM locking is no longer supported.]);
 fi
 if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
 	BUILDCMAN=yes
@@ -475,14 +472,6 @@
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
@@ -494,10 +483,9 @@
 
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
@@ -519,28 +507,6 @@
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
@@ -633,13 +599,6 @@
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
@@ -1354,8 +1313,6 @@
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GULM_CFLAGS)
-AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(INTL)
--- LVM2/daemons/clvmd/Makefile.in	2010/04/09 21:42:48	1.40
+++ LVM2/daemons/clvmd/Makefile.in	2011/08/09 18:11:00	1.41
@@ -25,8 +25,6 @@
 CPG_CFLAGS = @CPG_CFLAGS@
 DLM_LIBS = @DLM_LIBS@
 DLM_CFLAGS = @DLM_CFLAGS@
-GULM_LIBS = @GULM_LIBS@
-GULM_CFLAGS = @GULM_CFLAGS@
 QUORUM_LIBS = @QUORUM_LIBS@
 QUORUM_CFLAGS = @QUORUM_CFLAGS@
 SALCK_LIBS = @SALCK_LIBS@
@@ -42,13 +40,6 @@
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
@@ -76,7 +67,6 @@
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
-	SOURCES += clvmd-gulm.c tcp-comms.c
 	SOURCES += clvmd-cman.c
 	SOURCES += clvmd-openais.c
 	SOURCES += clvmd-corosync.c
--- LVM2/daemons/clvmd/clvmd-comms.h	2010/03/23 14:35:08	1.12
+++ LVM2/daemons/clvmd/clvmd-comms.h	2011/08/09 18:11:00	1.13
@@ -54,13 +54,6 @@
 
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
--- LVM2/daemons/clvmd/clvmd.c	2011/06/28 13:42:15	1.105
+++ LVM2/daemons/clvmd/clvmd.c	2011/08/09 18:11:00	1.106
@@ -78,7 +78,6 @@
 };
 
 struct lvm_startup_params {
-	int using_gulm;
 	char **argv;
 };
 
@@ -101,7 +100,7 @@
 #define DFAIL_TIMEOUT    5
 #define SUCCESS          0
 
-typedef enum {IF_AUTO, IF_CMAN, IF_GULM, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
+typedef enum {IF_AUTO, IF_CMAN, IF_OPENAIS, IF_COROSYNC, IF_SINGLENODE} if_type_t;
 
 /* Prototypes for code further down */
 static void sigusr2_handler(int sig);
@@ -166,9 +165,6 @@
 #ifdef USE_OPENAIS
 		"openais "
 #endif
-#ifdef USE_GULM
-		"gulm "
-#endif
 #ifdef USE_SINGLENODE
 		"singlenode "
 #endif
@@ -342,7 +338,6 @@
 	int start_timeout = 0;
 	if_type_t cluster_iface = IF_AUTO;
 	sigset_t ss;
-	int using_gulm = 0;
 	int debug_opt = 0;
 	debug_t debug_arg = DEBUG_OFF;
 	int clusterwide_opt = 0;
@@ -473,7 +468,7 @@
 
 	/* Set up signal handlers, USR1 is for cluster change notifications (in cman)
 	   USR2 causes child threads to exit.
-	   HUP causes gulm version to re-read nodes list from CCS.
+	   HUP causes to re-read nodes list from CCS.
 	   PIPE should be ignored */
 	signal(SIGUSR2, sigusr2_handler);
 	signal(SIGHUP,  sighup_handler);
@@ -505,16 +500,6 @@
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
@@ -580,14 +565,10 @@
 
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
 
@@ -625,7 +606,7 @@
 	return 0;
 }
 
-/* Called when the GuLM cluster layer has completed initialisation.
+/* Called when the cluster layer has completed initialisation.
    We send the version message */
 void clvmd_cluster_init_completed(void)
 {
@@ -1965,7 +1946,7 @@
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_clvm(lvm_params->using_gulm, lvm_params->argv);
+	init_clvm(lvm_params->argv);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
@@ -2222,8 +2203,6 @@
 		iface = IF_AUTO;
 	if (!strcmp(ifname, "cman"))
 		iface = IF_CMAN;
-	if (!strcmp(ifname, "gulm"))
-		iface = IF_GULM;
 	if (!strcmp(ifname, "openais"))
 		iface = IF_OPENAIS;
 	if (!strcmp(ifname, "corosync"))
--- LVM2/daemons/clvmd/lvm-functions.c	2011/06/11 00:03:06	1.119
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/08/09 18:11:00	1.120
@@ -650,46 +650,6 @@
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
@@ -920,7 +880,7 @@
 }
 
 /* Called to initialise the LVM context of the daemon */
-int init_clvm(int using_gulm, char **argv)
+int init_clvm(char **argv)
 {
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
@@ -942,10 +902,6 @@
 	check_config();
 	init_ignore_suspended_devices(1);
 
-	/* Remove any non-LV locks that may have been left around */
-	if (using_gulm)
-		drop_vg_locks();
-
 	get_initial_state(argv);
 
 	/* Trap log messages so we can pass them back to the user */
--- LVM2/daemons/clvmd/lvm-functions.h	2011/01/10 14:02:30	1.15
+++ LVM2/daemons/clvmd/lvm-functions.h	2011/08/09 18:11:00	1.16
@@ -27,7 +27,7 @@
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_clvm(int using_gulm, char **argv);
+extern int init_clvm(char **argv);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
--- LVM2/man/clvmd.8.in	2011/01/17 23:13:14	1.5
+++ LVM2/man/clvmd.8.in	2011/08/09 18:11:00	1.6
@@ -85,7 +85,7 @@
 Selects the cluster manager to use for locking and internal communications,
 the available managers will be listed as part of the 'clvmd -h' output.
 clvmd will use the first cluster manager that succeeds, and it checks them
-in the order cman,gulm,corosync,openais. As it is quite possible to have
+in the order cman,corosync,openais. As it is quite possible to have
 (eg) corosync and cman available on the same system you might have to
 manually specify this option to override the search.
 .TP


