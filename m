From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:19 +0200
Subject: [PATCH 07/25] Replicator: add _replicator_in_sync
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <d87b9a90313df001717ed7ef4244f8c530bc9fa9.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add function init_replicator_in_sync() to be similar as mirror.
For now this function is not functional.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/lvm-globals.c |   11 +++++++++++
 lib/misc/lvm-globals.h |    2 ++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 8dc2b02..5334691 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -34,6 +34,7 @@ static int _ignorelockingfailure = 0;
 static int _security_level = SECURITY_LEVEL;
 static char _cmd_name[30] = "";
 static int _mirror_in_sync = 0;
+static int _replicator_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _background_polling = DEFAULT_BACKGROUND_POLLING;
 static int _ignore_suspended_devices = 0;
@@ -88,6 +89,11 @@ void init_mirror_in_sync(int in_sync)
 	_mirror_in_sync = in_sync;
 }
 
+void init_replicator_in_sync(int in_sync)
+{
+	_replicator_in_sync = in_sync;
+}
+
 void init_dmeventd_monitor(int reg)
 {
 	_dmeventd_monitor = reg;
@@ -190,6 +196,11 @@ int mirror_in_sync(void)
 	return _mirror_in_sync;
 }
 
+int replicator_in_sync(void)
+{
+	return _replicator_in_sync;
+}
+
 int dmeventd_monitor_mode(void)
 {
 	return _dmeventd_monitor;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 0134c32..c08aa2e 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -31,6 +31,7 @@ void init_ignorelockingfailure(int level);
 void init_lockingfailed(int level);
 void init_security_level(int level);
 void init_mirror_in_sync(int in_sync);
+void init_replicator_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_background_polling(int polling);
 void init_ignore_suspended_devices(int ignore);
@@ -51,6 +52,7 @@ int ignorelockingfailure(void);
 int lockingfailed(void);
 int security_level(void);
 int mirror_in_sync(void);
+int replicator_in_sync(void);
 int background_polling(void);
 int ignore_suspended_devices(void);
 const char *log_command_name(void);
-- 
1.7.2.1


