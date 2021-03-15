From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:10 +0000 (GMT)
Subject: main - config: correct option name
Message-ID: <20210315101410.5DF263858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ff712987a5792cfc3fba03889ec4485294386a03
Commit:        ff712987a5792cfc3fba03889ec4485294386a03
Parent:        b4dfe026dd38a3d84de48664f357828f05b36da2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 13 20:35:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:59:24 2021 +0100

config: correct option name

---
 conf/example.conf.in         | 2 +-
 lib/config/config_settings.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 204ec82d1..215a30f86 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1335,7 +1335,7 @@ activation {
 
 	# Configuration option activation/udev_sync.
 	# Use udev notifications to synchronize udev and LVM.
-	# The --nodevsync option overrides this setting.
+	# The --noudevsync option overrides this setting.
 	# When disabled, LVM commands will not wait for notifications from
 	# udev, but continue irrespective of any possible udev processing in
 	# the background. Only use this if udev is not running or has rules
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index fac5d6317..3000a4be1 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1323,7 +1323,7 @@ cfg(global_io_memory_size_CFG, "io_memory_size", global_CFG_SECTION, CFG_DEFAULT
 
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
-	"The --nodevsync option overrides this setting.\n"
+	"The --noudevsync option overrides this setting.\n"
 	"When disabled, LVM commands will not wait for notifications from\n"
 	"udev, but continue irrespective of any possible udev processing in\n"
 	"the background. Only use this if udev is not running or has rules\n"


