From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:03:05 +0000 (UTC)
Subject: master - debug: do not play with fds with valgring
Message-ID: <20121012150305.C8F4B222C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31d8c3ee856b3021f531bfcb92d71811d7e3d575
Commit:        31d8c3ee856b3021f531bfcb92d71811d7e3d575
Parent:        ee7143cd02d4b26c80b7accbb80d570058cbe9a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 16:52:38 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:02:30 2012 +0200

debug: do not play with fds with valgring

When valgrind usage is desired by user (--enable-valgrind-pool)
skip playing/closing/reopenning with descriptors - it makes
valgridng useless.

Make sleep delay for clvmd start longer.
---
 lib/commands/toolcontext.c |    4 ++++
 test/lib/aux.sh            |    2 +-
 tools/lvmcmdline.c         |    2 ++
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d89d2b4..d72b0c0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1349,6 +1349,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	/* FIXME Make this configurable? */
 	reset_lvm_errno(1);
 
+#ifndef VALGRIND_POOL
 	/* Set in/out stream buffering before glibc */
 	if (set_buffering) {
 		/* Allocate 2 buffers */
@@ -1381,6 +1382,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	} else
 		/* Without buffering, must not use stdin/stdout */
 		init_silent(1);
+#endif
 
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
@@ -1649,6 +1651,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
+#ifndef VALGRIND_POOL
 	if (cmd->linebuffer) {
 		/* Reset stream buffering to defaults */
 		if (is_valid_fd(STDIN_FILENO)) {
@@ -1669,6 +1672,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 		dm_free(cmd->linebuffer);
 	}
+#endif
 
 	dm_free(cmd);
 
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f179e31..4b56fb6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -42,7 +42,7 @@ prepare_clvmd() {
 	local local_clvmd=$!
 	sleep .3
 	# extra sleep for slow valgrind
-	test -z "$LVM_VALGRIND_CLVMD" || sleep 5
+	test -z "$LVM_VALGRIND_CLVMD" || sleep 7
 	# check that it is really running now
 	ps $local_clvmd || die
 	echo $local_clvmd > LOCAL_CLVMD
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index efcefe3..39a8c58 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1292,6 +1292,7 @@ static void _close_descriptor(int fd, unsigned suppress_warnings,
 
 static int _close_stray_fds(const char *command)
 {
+#ifndef VALGRIND_POOL
 	struct rlimit rlim;
 	int fd;
 	unsigned suppress_warnings = 0;
@@ -1331,6 +1332,7 @@ static int _close_stray_fds(const char *command)
 
 	if (closedir(d))
 		log_sys_error("closedir", _fd_dir);
+#endif
 
 	return 1;
 }


