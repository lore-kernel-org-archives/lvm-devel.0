From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:14 +0000 (UTC)
Subject: master - clvmd: preserve foreground mode across restart
Message-ID: <20130421211614.7104F145A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0125518d6d0a0fce63998fc898c203255ad73700
Commit:        0125518d6d0a0fce63998fc898c203255ad73700
Parent:        c9d8d22224f5516f364bd66ce41aa506a39801a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 20 22:23:36 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:56:48 2013 +0200

clvmd: preserve foreground mode across restart

Keep clvmd in foreground when restarted.
Useful for testing.
---
 daemons/clvmd/clvmd-command.c |    8 ++++++--
 daemons/clvmd/clvmd.c         |    5 +++++
 daemons/clvmd/clvmd.h         |    1 +
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index c5cd461..5d93f38 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -383,7 +383,7 @@ static int restart_clvmd(void)
 	} while (hn);
 
 	/* clvmd + locks (-E uuid) + debug (-d X) + NULL */
-	if (!(argv = malloc((max_locks * 2 + 5) * sizeof(*argv))))
+	if (!(argv = malloc((max_locks * 2 + 6) * sizeof(*argv))))
 		goto_out;
 
 	/*
@@ -391,13 +391,17 @@ static int restart_clvmd(void)
 	 */
 	argv[argc++] = "clvmd";
 
-	/* Propogate debug options */
+	/* Propagate debug options */
 	if (clvmd_get_debug()) {
 		if (dm_snprintf(debug_arg, sizeof(debug_arg), "-d%u", clvmd_get_debug()) < 0)
 			goto_out;
 		argv[argc++] = debug_arg;
 	}
 
+	/* Propagate foreground options */
+	if (clvmd_get_foreground())
+		argv[argc++] = "-f";
+
 	argv[argc++] = "-I";
 	argv[argc++] = clops->name;
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 54cf1ac..c649bbe 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -249,6 +249,11 @@ debug_t clvmd_get_debug(void)
 	return debug;
 }
 
+int clvmd_get_foreground(void)
+{
+	return foreground_mode;
+}
+
 static const char *decode_cmd(unsigned char cmdl)
 {
 	static char buf[128];
diff --git a/daemons/clvmd/clvmd.h b/daemons/clvmd/clvmd.h
index 5bad43a..67ea41e 100644
--- a/daemons/clvmd/clvmd.h
+++ b/daemons/clvmd/clvmd.h
@@ -119,6 +119,7 @@ extern void debuglog(const char *fmt, ... )
 
 void clvmd_set_debug(debug_t new_de);
 debug_t clvmd_get_debug(void);
+int clvmd_get_foreground(void);
 
 int sync_lock(const char *resource, int mode, int flags, int *lockid);
 int sync_unlock(const char *resource, int lockid);


