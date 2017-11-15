From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Nov 2017 20:03:50 -0500
Subject: master - log: Add io debug class
Message-ID: <201711150103.vAF13olo000501@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02e987666540712a9467025bf36e46e041da2611
Commit:        02e987666540712a9467025bf36e46e041da2611
Parent:        b5f62a143dcc83bcc12910400b177620a8f49b7c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 15 00:59:30 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 15 01:02:15 2017 +0000

log: Add io debug class

---
 WHATS_NEW                    |    1 +
 lib/commands/toolcontext.c   |    2 ++
 lib/config/config_settings.h |    4 ++--
 lib/device/dev-io.c          |    5 +++++
 lib/log/log.h                |    2 ++
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 04229da..7db534c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Add "io" to log/debug_classes for logging low-level I/O.
   Eliminate redundant nested VG metadata in VG struct.
   Avoid importing persistent filter in vgscan/pvscan/vgrename.
   Fix memleak of string buffer when vgcfgbackup runs in secure mode.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e742df5..1985c30 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -283,6 +283,8 @@ static int _parse_debug_classes(struct cmd_context *cmd)
 			debug_classes |= LOG_CLASS_LVMPOLLD;
 		else if (!strcasecmp(cv->v.str, "dbus"))
 			debug_classes |= LOG_CLASS_DBUS;
+		else if (!strcasecmp(cv->v.str, "io"))
+			debug_classes |= LOG_CLASS_IO;
 		else
 			log_verbose("Unrecognised value for log/debug_classes: %s", cv->v.str);
 	}
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7d800b3..077fb15 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -705,11 +705,11 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 
 cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sio#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
 	"Some debugging messages are assigned to a class and only appear in\n"
 	"debug output if the class is listed here. Classes currently\n"
-	"available: memory, devices, activation, allocation, lvmetad,\n"
+	"available: memory, devices, io, activation, allocation, lvmetad,\n"
 	"metadata, cache, locking, lvmpolld. Use \"all\" to see everything.\n")
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 328ec30..24bc81c 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -72,6 +72,11 @@ static int _io(struct device_area *where, char *buffer, int should_write)
 		return 0;
 	}
 
+	log_debug_io("%s %s:%8" PRIu64 " bytes (sync) at %" PRIu64 "%s",
+		     should_write ? "Write" : "Read ", dev_name(where->dev),
+		     where->size, (uint64_t) where->start,
+		     (should_write && test_mode()) ? " (test mode - suppressed)" : "");
+
 	/*
 	 * Skip all writes in test mode.
 	 */
diff --git a/lib/log/log.h b/lib/log/log.h
index 0ce4fda..256fed0 100644
--- a/lib/log/log.h
+++ b/lib/log/log.h
@@ -72,6 +72,7 @@
 #define LOG_CLASS_LOCKING	0x0080	/* "locking" */
 #define LOG_CLASS_LVMPOLLD	0x0100	/* "lvmpolld" */
 #define LOG_CLASS_DBUS		0x0200	/* "dbus" */
+#define LOG_CLASS_IO		0x0400	/* "io" */
 
 #define log_debug(x...) LOG_LINE(_LOG_DEBUG, x)
 #define log_debug_mem(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_MEM, x)
@@ -84,6 +85,7 @@
 #define log_debug_locking(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LOCKING, x)
 #define log_debug_lvmpolld(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_LVMPOLLD, x)
 #define log_debug_dbus(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_DBUS, x)
+#define log_debug_io(x...) LOG_LINE_WITH_CLASS(_LOG_DEBUG, LOG_CLASS_IO, x)
 
 #define log_info(x...) LOG_LINE(_LOG_INFO, x)
 #define log_notice(x...) LOG_LINE(_LOG_NOTICE, x)


