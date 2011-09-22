From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Sep 2011 11:52:50 +0200
Subject: [PATCH 3/3] CLVMD support for CLVMD_BINARY and LVM_BINARY
In-Reply-To: <cover.1316684951.git.zkabelac@redhat.com>
References: <cover.1316684951.git.zkabelac@redhat.com>
Message-ID: <d790e83a3147fc29b98ba1f3535e59b6ce9ecbc6.1316684951.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Read 2 environmental vars to learn about overide position for
CLVMD and LVM binaries.

We support LVM_BINARY in other script - and this way we could easily
test restart in our test-suite.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                  |    9 ++++++---
 daemons/clvmd/clvmd-command.c |    5 +++--
 daemons/clvmd/lvm-functions.c |   19 ++++++++++++++-----
 man/Makefile.in               |    2 +-
 man/clvmd.8.in                |   10 ++++++++++
 5 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/configure.in b/configure.in
index 30dd765..244bfc8 100644
--- a/configure.in
+++ b/configure.in
@@ -1180,13 +1180,14 @@ fi
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
@@ -1309,6 +1310,7 @@ AC_SUBST(CLDWHOLEARCHIVE)
 AC_SUBST(CLUSTER)
 AC_SUBST(CLVMD)
 AC_SUBST(CLVMD_CMANAGERS)
+AC_SUBST(CLVMD_PATH)
 AC_SUBST(CMAN_CFLAGS)
 AC_SUBST(CMAN_LIBS)
 AC_SUBST(CMDLIB)
@@ -1357,6 +1359,7 @@ AC_SUBST(LVM_LIBAPI)
 AC_SUBST(LVM_MAJOR)
 AC_SUBST(LVM_MINOR)
 AC_SUBST(LVM_PATCHLEVEL)
+AC_SUBST(LVM_PATH)
 AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index bd6e55e..e1ded83 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -366,6 +366,7 @@ static int restart_clvmd(void)
 	int argc = 0, max_locks = 0;
 	struct dm_hash_node *hn = NULL;
 	char debug_arg[16];
+	const char *clvmd_binary = getenv("CLVMD_BINARY") ? : CLVMD_PATH;
 
 	DEBUGLOG("clvmd restart requested\n");
 
@@ -413,11 +414,11 @@ static int restart_clvmd(void)
 	argv[argc] = NULL;
 
 	/* Exec new clvmd */
-	DEBUGLOG("--- Restarting %s ---\n", CLVMD_PATH);
+	DEBUGLOG("--- Restarting %s ---\n", clvmd_binary);
 	for (argc = 1; argv[argc]; argc++) DEBUGLOG("--- %d: %s\n", argc, argv[argc]);
 
 	/* NOTE: This will fail when downgrading! */
-	execve(CLVMD_PATH, (char **)argv, NULL);
+	execve(clvmd_binary, (char **)argv, NULL);
 out:
 	/* We failed */
 	DEBUGLOG("Restart of clvmd failed.\n");
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index ba786bb..f16d006 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -704,14 +704,21 @@ static int get_initial_state(struct dm_hash_table *excl_uuid)
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
 
-	if (!lvs)
+	if (dm_asprintf(&lvs_cmd, "%s lvs  --config 'log{command_names=0 prefix=\"\"}' "
+			"--nolocking --noheadings -o vg_uuid,lv_uuid,lv_attr,vg_attr",
+			lvm_binary) < 0)
 		return 0;
 
+	/* FIXME: Maybe link and use liblvm2cmd directly instead of fork */
+	if (!(lvs = popen(lvs_cmd, "r"))) {
+		dm_free(lvs_cmd);
+		return 0;
+	}
+
 	while (fgets(line, sizeof(line), lvs)) {
 	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
 
@@ -749,6 +756,8 @@ static int get_initial_state(struct dm_hash_table *excl_uuid)
 	if (fclose(lvs))
 		DEBUGLOG("lvs fclose failed: %s\n", strerror(errno));
 
+	dm_free(lvs_cmd);
+
 	return 1;
 }
 
diff --git a/man/Makefile.in b/man/Makefile.in
index 2506fbd..3fb39b7 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -73,7 +73,7 @@ $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 %: %.in
 	@case "$@" in \
 	  */*) ;; \
-	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" $< > $@ ;; \
+	  *) echo "Creating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+ at CLVMD_PATH@+;s+#LVM_PATH#+ at LVM_PATH@+;" $< > $@ ;; \
 	esac
 
 install_man5: $(MAN5)
diff --git a/man/clvmd.8.in b/man/clvmd.8.in
index 22d94b2..0d1ed56 100644
--- a/man/clvmd.8.in
+++ b/man/clvmd.8.in
@@ -95,5 +95,15 @@ manually specify this option to override the search.
 .TP
 .I \-V
 Display the version of the cluster LVM daemon.
+
+.SH ENVIRONMENT VARIABLES
+.TP
+.B CLVMD_BINARY
+The CLVMD binary to use when clmvd restart is requested.
+Defaults to #CLVMD_PATH#.
+.TP
+.B LVM_BINARY
+The LVM2 binary to use. Defaults to #LVM_PATH#.
+
 .SH SEE ALSO
 .BR lvm (8)
-- 
1.7.6.2


