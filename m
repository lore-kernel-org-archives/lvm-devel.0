From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:27 +0000 (UTC)
Subject: master - config_settings.h: improve lvmpolld config description
Message-ID: <20150515183727.5DF1060E34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f0095fa2c2c3ceb542be7d3da54072dd6c2bef5
Commit:        9f0095fa2c2c3ceb542be7d3da54072dd6c2bef5
Parent:        bf19bbbd5596ea55111678c56087672ee1b72c11
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 15 14:26:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:51 2015 +0200

config_settings.h: improve lvmpolld config description

---
 lib/config/config_settings.h |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index cfcc72e..4e1c126 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -937,13 +937,16 @@ cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"this only when there seems to be a problem.\n")
 
 cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), NULL, 0, NULL,
-	"Indicates whether to use lvmpolld instead of classical polldaemon (a process\n"
-	"forked off an initiating lvm command) or not. When set to 1 and native systemd\n"
-	"service is installed in the system lvm starts using lvmpolld. lvmpolld gets\n"
-	"auto-activated by systemd when a message lands on the respective lvmpolld socket.\n"
-	"All commands that would require polling of in-progress operation are therefore\n"
-	"spawned in lvmpolld's service cgroup.\n"
-	"When set to 0 lvm falls back to classical polling.\n")
+	"Use lvmpolld to supervise long running LVM commands.\n"
+	"When enabled, control of long running LVM commands is transferred\n"
+	"from the original LVM command to the lvmpolld daemon.  This allows\n"
+	"the operation to continue independent of the original LVM command.\n"
+	"After lvmpolld takes over, the LVM command displays the progress\n"
+	"of the ongoing operation.  lvmpolld itself runs LVM commands to manage\n"
+	"the progress of ongoing operations.  lvmpolld can be used as a native\n"
+	"systemd service, which allows it to be started on demand, and to use\n"
+	"its own control group.  When this option is disabled, LVM commands will\n"
+	"supervise long running operations by forking themselves.\n")
 
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"


