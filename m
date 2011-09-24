From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 20:50:37 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in da ...
Message-ID: <20110924205037.29958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 20:50:36

Modified files:
	.              : WHATS_NEW configure configure.in 
	daemons/clvmd  : clvmd-command.c lvm-functions.c 
	man            : Makefile.in clvmd.8.in 

Log message:
	CLVMD support for LVM_CLVMD_BINARY and LVM_BINARY
	
	Read 2 environmental vars to learn about overide position for
	CLVMD and LVM binaries.
	
	We support LVM_BINARY in other script - and this way we could easily
	test restart in our test-suite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2134&r2=1.2135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2011/09/24 20:48:34	1.2134
+++ LVM2/WHATS_NEW	2011/09/24 20:50:35	1.2135
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Support env vars LVM_CLVMD_BINARY and LVM_BINARY in clvmd.
   Fix restart of clvmd (preserve exlusive locks). (2.02.64)
   Add 'Volume Type' lv_attr characters for RAID and RAID_IMAGE.
   Add activation/retry_deactivation to lvm.conf to retry deactivation of an LV.
--- LVM2/configure	2011/08/31 11:39:32	1.157
+++ LVM2/configure	2011/09/24 20:50:35	1.158
@@ -626,6 +626,7 @@
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
+LVM_PATH
 LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
@@ -664,6 +665,7 @@
 COPTIMISE_FLAG
 CONFDIR
 CMDLIB
+CLVMD_PATH
 CLVMD_CMANAGERS
 CLVMD
 CLUSTER
@@ -9913,18 +9915,20 @@
 lvm_exec_prefix=$exec_prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
+LVM_PATH="$lvm_exec_prefix/sbin/lvm"
 
 cat >>confdefs.h <<_ACEOF
-#define LVM_PATH "$lvm_exec_prefix/sbin/lvm"
+#define LVM_PATH "$LVM_PATH"
 _ACEOF
 
 
 if  test "$CLVMD" != none; then
         clvmd_prefix=$ac_default_prefix
+        CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
         test "$prefix" != NONE && clvmd_prefix=$prefix
 
 cat >>confdefs.h <<_ACEOF
-#define CLVMD_PATH "$clvmd_prefix/sbin/clvmd"
+#define CLVMD_PATH "$CLVMD_PATH"
 _ACEOF
 
 fi
@@ -10205,6 +10209,8 @@
 
 
 
+
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile !
 test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2011/08/31 11:31:57	1.171
+++ LVM2/configure.in	2011/09/24 20:50:36	1.172
@@ -1180,13 +1180,14 @@
 lvm_exec_prefix=$exec_prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
-AC_DEFINE_UNQUOTED(LVM_PATH, ["$lvm_exec_prefix/sbin/lvm"], [Path to lvm binary.])
+LVM_PATH="$lvm_exec_prefix/sbin/lvm"
+AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
 if  test "$CLVMD" != none; then
         clvmd_prefix=$ac_default_prefix
+        CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
         test "$prefix" != NONE && clvmd_prefix=$prefix
-	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$clvmd_prefix/sbin/clvmd"],
-			   [Path to clvmd binary.])
+	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 fi
 
 ################################################################################
@@ -1309,6 +1310,7 @@
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CLVMD_CMANAGERS)
+AC_SUBST(CLVMD_PATH)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
@@ -1357,6 +1359,7 @@
 AC_SUBST(LVM_MAJOR)
 AC_SUBST(LVM_MINOR)
 AC_SUBST(LVM_PATCHLEVEL)
+AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
--- LVM2/daemons/clvmd/clvmd-command.c	2011/09/22 09:47:34	1.58
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/09/24 20:50:36	1.59
@@ -366,6 +366,7 @@
 	int argc = 0, max_locks = 0;
 	struct dm_hash_node *hn = NULL;
 	char debug_arg[16];
+	const char *clvmd = getenv("LVM_CLVMD_BINARY") ? : CLVMD_PATH;
 
 	DEBUGLOG("clvmd restart requested\n");
 
@@ -415,11 +416,11 @@
 	argv[argc] = NULL;
 
 	/* Exec new clvmd */
-	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
+	DEBUGLOG("--- Restarting %s ---\n", clvmd);
 	for (argc = 1; argv[argc]; argc++) DEBUGLOG("--- %d: %s\n", argc, argv[argc]);
 
 	/* NOTE: This will fail when downgrading! */
-	execve(CLVMD_PATH, (char **)argv, NULL);
+	execve(clvmd, (char **)argv, NULL);
 out:
 	/* We failed */
 	DEBUGLOG("Restart of clvmd failed.\n");
--- LVM2/daemons/clvmd/lvm-functions.c	2011/09/24 20:48:34	1.123
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/09/24 20:50:36	1.124
@@ -704,13 +704,20 @@
 	char lv[64], vg[64], flags[25], vg_flags[25];
 	char uuid[65];
 	char line[255];
-	FILE *lvs =
-	    popen
-	    (LVM_PATH " lvs  --config 'log{command_names=0 prefix=\"\"}' --nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
-	     "r");
+	char *lvs_cmd;
+	const char *lvm_binary = getenv("LVM_BINARY") ? : LVM_PATH;
+	FILE *lvs;
+
+	if (dm_asprintf(&lvs_cmd, "%s lvs  --config 'log{command_names=0 prefix=\"\"}' "
+			"--nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
+			lvm_binary) < 0)
+		return 0;
 
-	if (!lvs)
+	/* FIXME: Maybe link and use liblvm2cmd directly instead of fork */
+	if (!(lvs = popen(lvs_cmd, "r"))) {
+		dm_free(lvs_cmd);
 		return 0;
+	}
 
 	while (fgets(line, sizeof(line), lvs)) {
 	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
@@ -749,6 +756,8 @@
 	if (fclose(lvs))
 		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
 
+	dm_free(lvs_cmd);
+
 	return 1;
 }
 
--- LVM2/man/Makefile.in	2011/09/23 17:05:44	1.42
+++ LVM2/man/Makefile.in	2011/09/24 20:50:36	1.43
@@ -73,7 +73,7 @@
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
--- LVM2/man/clvmd.8.in	2011/09/24 20:48:34	1.7
+++ LVM2/man/clvmd.8.in	2011/09/24 20:50:36	1.8
@@ -95,5 +95,15 @@
 .TP
 .I \-V
 Display the version of the cluster LVM daemon.
+
+.SH ENVIRONMENT VARIABLES
+.TP
+.B LVM_CLVMD_BINARY
+The CLVMD binary to use when clmvd restart is requested.
+Defaults to #CLVMD_PATH#.
+.TP
+.B LVM_BINARY
+The LVM2 binary to use. Defaults to #LVM_PATH#.
+
 .SH SEE ALSO
 .BR lvm (8)


