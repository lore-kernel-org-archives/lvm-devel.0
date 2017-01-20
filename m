From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:03:59 +0000 (UTC)
Subject: master - config: new option dmeventd/thin_command
Message-ID: <20170120230359.49BEA60D79@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04a9cad499848cfc025d33ca28e9f657abc80ca3
Commit:        04a9cad499848cfc025d33ca28e9f657abc80ca3
Parent:        ee754500dbb3787b1b9339e59dc4335a9b6c58cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 09:54:32 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:53:26 2017 +0100

config: new option dmeventd/thin_command

This setting will allowing configuring which command gets executed
when thin-pool fullness goes from 50%..100%
---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |    8 ++++++++
 lib/config/config_settings.h |    6 ++++++
 lib/config/defaults.h        |    1 +
 4 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f0d131..e5b735f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Introduce new dmeventd/thin_command configurable setting.
   Use new default units 'r' for displaying sizes.
   Also unmount mount point on top of MD device if using blkdeactivate -u.
   Restore check preventing resize of cache type volumes (2.02.158).
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 91d7072..7cb6f4a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -2049,6 +2049,14 @@ dmeventd {
 	# warning is repeated when 85%, 90% and 95% of the pool is filled.
 	thin_library = "libdevmapper-event-lvm2thin.so"
 
+	# Configuration option dmeventd/thin_command.
+	# The plugin runs command with each 5% increment when thin-pool data volume
+	# or metadata volume gets above 50%.
+	# Command which starts with 'lvm ' prefix is internal lvm command.
+	# You can write your own handler to customise behaviour in more details.
+	# This configuration option has an automatic default value.
+	# thin_command = "lvm lvextend --use-policies"
+
 	# Configuration option dmeventd/executable.
 	# The full path to the dmeventd binary.
 	# This configuration option has an automatic default value.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e0770b6..8f49b12 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1859,6 +1859,12 @@ cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE
 	"and emits a warning through syslog when the usage exceeds 80%. The\n"
 	"warning is repeated when 85%, 90% and 95% of the pool is filled.\n")
 
+cfg(dmeventd_thin_command_CFG, "thin_command", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_COMMAND, vsn(2, 2, 169), NULL, 0, NULL,
+	"The plugin runs command with each 5% increment when thin-pool data volume\n"
+	"or metadata volume gets above 50%.\n"
+	"Command which starts with 'lvm ' prefix is internal lvm command.\n"
+	"You can write your own handler to customise behaviour in more details.\n")
+
 cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5479cc5..26bbc69 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -81,6 +81,7 @@
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
 #define DEFAULT_DMEVENTD_THIN_LIB "libdevmapper-event-lvm2thin.so"
+#define DEFAULT_DMEVENTD_THIN_COMMAND "lvm lvextend --use-policies"
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 


