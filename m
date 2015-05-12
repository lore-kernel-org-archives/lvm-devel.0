From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 May 2015 15:22:16 +0000 (UTC)
Subject: master - new debug class for lvmpolld client code
Message-ID: <20150512152216.7B5826026A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3d351ec9b4d98a08b4d5556130870332f650b67
Commit:        c3d351ec9b4d98a08b4d5556130870332f650b67
Parent:        e213aa17bd9ef648f8fc44047ab4bd8c8ff80959
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 12 15:26:26 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 12 17:16:37 2015 +0200

new debug class for lvmpolld client code

---
 conf/example.conf.in         |    4 ++--
 lib/commands/toolcontext.c   |    2 ++
 lib/config/config_settings.h |    4 ++--
 lib/config/defaults.h        |    3 ++-
 lib/log/log.h                |    2 ++
 5 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 843e62d..fc27a98 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -500,10 +500,10 @@ log {
 	# and only appear in debug output if the class is
 	# listed here.  Classes currently available:
 	# memory, devices, activation, allocation,
-	# lvmetad, metadata, cache, locking.
+	# lvmetad, metadata, cache, locking, lvmpolld.
 	# Use "all" to see everything.
 	debug_classes = ["memory", "devices", "activation", "allocation",
-			 "lvmetad", "metadata", "cache", "locking"]
+			 "lvmetad", "metadata", "cache", "locking", "lvmpolld"]
 }
 
 # Configuration section backup.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 43d878b..47aa209 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -274,6 +274,8 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 			debug_classes |= LOG_CLASS_CACHE;
 		else if (!strcasecmp(cv->v.str, "locking"))
 			debug_classes |= LOG_CLASS_LOCKING;
+		else if (!strcasecmp(cv->v.str, "lvmpolld"))
+			debug_classes |= LOG_CLASS_LVMPOLLD;
 		else
 			log_verbose("Unrecognised value for log/debug_classes: %s", cv->v.str);
 	}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2bbafc3..4fd886d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -546,13 +546,13 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 
 cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
 	"Some debugging messages are assigned to a class\n"
 	"and only appear in debug output if the class is\n"
 	"listed here.  Classes currently available:\n"
 	"memory, devices, activation, allocation,\n"
-	"lvmetad, metadata, cache, locking.\n"
+	"lvmetad, metadata, cache, locking, lvmpolld.\n"
 	"Use \"all\" to see everything.\n")
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index b745662..6793d01 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -144,7 +144,8 @@
 
 #define DEFAULT_LOGGED_DEBUG_CLASSES (LOG_CLASS_MEM | LOG_CLASS_DEVS | \
     LOG_CLASS_ACTIVATION | LOG_CLASS_ALLOC | LOG_CLASS_LVMETAD | \
-    LOG_CLASS_METADATA | LOG_CLASS_CACHE | LOG_CLASS_LOCKING)
+    LOG_CLASS_METADATA | LOG_CLASS_CACHE | LOG_CLASS_LOCKING | \
+    LOG_CLASS_LVMPOLLD)
 
 #define DEFAULT_SYSLOG 1
 #define DEFAULT_VERBOSE 0
diff --git a/lib/log/log.h b/lib/log/log.h
index 75a6220..79e7d77 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -67,6 +67,7 @@
 #define LOG_CLASS_METADATA	0x0020	/* "metadata" */
 #define LOG_CLASS_CACHE		0x0040	/* "cache" */
 #define LOG_CLASS_LOCKING	0x0080	/* "locking" */
+#define LOG_CLASS_LVMPOLLD	0x0100	/* "lvmpolld" */
 
 #define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
 #define log_debug_mem(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_MEM, x)
@@ -77,6 +78,7 @@
 #define log_debug_metadata(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_METADATA, x)
 #define log_debug_cache(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_CACHE, x)
 #define log_debug_locking(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LOCKING, x)
+#define log_debug_lvmpolld(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LVMPOLLD, x)
 
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
 #define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)


