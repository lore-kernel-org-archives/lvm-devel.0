From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:09 +0000 (UTC)
Subject: master - tools: update for lvm2_disable_dmeventd_monitoring
Message-ID: <20151023085509.33D96610F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5b686d6932be9931a386d15e8d452153225952b
Commit:        e5b686d6932be9931a386d15e8d452153225952b
Parent:        87a39d8bac572b67f927dad41548155606a50f4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 10:48:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

tools: update for lvm2_disable_dmeventd_monitoring

Make lvm2_disable_dmeventd_monitoring() more explicit.

As memlock_inc_daemon() is also used by clvmd, which
does changes dmeventd and suspend ignore state at
some stages - make updates of these 2 variable
tied to the call of  lvm2_disable_dmeventd_monitoring().

Once this call is made dmeventd monitoring
and suspended devices are ignored.

TODO: all lvm-global settings should really be moved
to command context.
---
 lib/misc/lvm-globals.c |   11 +++++++++--
 lib/misc/lvm-globals.h |    1 +
 tools/lvmcmdlib.c      |    4 ++--
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 0cdcc88..06c36e2 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -40,6 +40,8 @@ static int _security_level = SECURITY_LEVEL;
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
+/* When set, disables update of _dmeventd_monitor & _ignore_suspended_devices */
+static int _disable_dmeventd_monitoring = 0;
 static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
 static int _ignore_lvm_mirrors = DEFAULT_IGNORE_LVM_MIRRORS;
@@ -123,10 +125,15 @@ void init_mirror_in_sync(int in_sync)
 
 void init_dmeventd_monitor(int reg)
 {
-	if (!memlock_count_daemon())
+	if (!_disable_dmeventd_monitoring)
 		_dmeventd_monitor = reg;
 }
 
+void init_disable_dmeventd_monitoring(int reg)
+{
+	_disable_dmeventd_monitoring = reg;
+}
+
 void init_background_polling(int polling)
 {
 	_background_polling = polling;
@@ -134,7 +141,7 @@ void init_background_polling(int polling)
 
 void init_ignore_suspended_devices(int ignore)
 {
-	if (!memlock_count_daemon())
+	if (!_disable_dmeventd_monitoring)
 		_ignore_suspended_devices = ignore;
 }
 
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 8628a89..132af96 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -38,6 +38,7 @@ void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
+void init_disable_dmeventd_monitoring(int disable);
 void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
 void init_ignore_lvm_mirrors(int scan);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index ae8ff5c..b30cce0 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -80,8 +80,6 @@ int lvm2_run(void *handle, const char *cmdline)
 	/* FIXME Temporary - move to libdevmapper */
 	ret = ECMD_PROCESSED;
 	if (!strcmp(cmdline, "_memlock_inc")) {
-		init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
-		init_ignore_suspended_devices(1);
 		memlock_inc_daemon(cmd);
 	} else if (!strcmp(cmdline, "_memlock_dec"))
 		memlock_dec_daemon(cmd);
@@ -99,6 +97,8 @@ int lvm2_run(void *handle, const char *cmdline)
 
 void lvm2_disable_dmeventd_monitoring(void *handle) {
 	init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+	init_ignore_suspended_devices(1);
+	init_disable_dmeventd_monitoring(1); /* Lock settings */
 }
 
 void lvm2_log_level(void *handle, int level)


