From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:47 +0000 (UTC)
Subject: master - config: update doc
Message-ID: <20170213091447.A269560E6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b185a3e3334e72c3aae6791ec4cb8768d55e0b9b
Commit:        b185a3e3334e72c3aae6791ec4cb8768d55e0b9b
Parent:        aa0c735e2ccbea969bad846f3e89c91a81d88fbf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 13 09:58:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:07 2017 +0100

config: update doc

---
 conf/example.conf.in         |    1 +
 lib/config/config_settings.h |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 7cb6f4a..5e238e4 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -2054,6 +2054,7 @@ dmeventd {
 	# or metadata volume gets above 50%.
 	# Command which starts with 'lvm ' prefix is internal lvm command.
 	# You can write your own handler to customise behaviour in more details.
+	# User handler is specified with the full path starting with '/'.
 	# This configuration option has an automatic default value.
 	# thin_command = "lvm lvextend --use-policies"
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 8f49b12..1d9603f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1863,7 +1863,9 @@ cfg(dmeventd_thin_command_CFG, "thin_command", dmeventd_CFG_SECTION, CFG_DEFAULT
 	"The plugin runs command with each 5% increment when thin-pool data volume\n"
 	"or metadata volume gets above 50%.\n"
 	"Command which starts with 'lvm ' prefix is internal lvm command.\n"
-	"You can write your own handler to customise behaviour in more details.\n")
+	"You can write your own handler to customise behaviour in more details.\n"
+	"User handler is specified with the full path starting with '/'.\n")
+	/* TODO: systemd service handler */
 
 cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")


