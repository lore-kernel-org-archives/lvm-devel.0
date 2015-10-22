From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:20 +0000 (UTC)
Subject: master - tools: preselect some setting for memlocked daemons
Message-ID: <20151022213320.58F8560DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2c4ce254bac0f607676b10e38ba2f2ebee709b8
Commit:        d2c4ce254bac0f607676b10e38ba2f2ebee709b8
Parent:        7b78d496bf4e80dab82824a70b1d1d852e7cc1fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:44:38 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:26:30 2015 +0200

tools: preselect some setting for memlocked daemons

When our daemon is locked into memory - avoid
communication with dmeventd and also skip
suspended devices.
---
 lib/misc/lvm-globals.c |    6 ++++--
 tools/lvmcmdlib.c      |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 60397e5..0cdcc88 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -123,7 +123,8 @@ void init_mirror_in_sync(int in_sync)
 
 void init_dmeventd_monitor(int reg)
 {
-	_dmeventd_monitor = reg;
+	if (!memlock_count_daemon())
+		_dmeventd_monitor = reg;
 }
 
 void init_background_polling(int polling)
@@ -133,7 +134,8 @@ void init_background_polling(int polling)
 
 void init_ignore_suspended_devices(int ignore)
 {
-	_ignore_suspended_devices = ignore;
+	if (!memlock_count_daemon())
+		_ignore_suspended_devices = ignore;
 }
 
 void init_ignore_lvm_mirrors(int scan)
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 26f160f..ae8ff5c 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -79,9 +79,11 @@ int lvm2_run(void *handle, const char *cmdline)
 
 	/* FIXME Temporary - move to libdevmapper */
 	ret = ECMD_PROCESSED;
-	if (!strcmp(cmdline, "_memlock_inc"))
+	if (!strcmp(cmdline, "_memlock_inc")) {
+		init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+		init_ignore_suspended_devices(1);
 		memlock_inc_daemon(cmd);
-	else if (!strcmp(cmdline, "_memlock_dec"))
+	} else if (!strcmp(cmdline, "_memlock_dec"))
 		memlock_dec_daemon(cmd);
 	else
 		ret = lvm_run_command(cmd, argc, argv);


