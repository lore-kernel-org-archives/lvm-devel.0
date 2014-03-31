From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 31 Mar 2014 13:59:33 +0000 (UTC)
Subject: master - config: fix compile error in config-settings.h if using --disable-dmeventd
Message-ID: <20140331135933.BDE28612B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68bb639a08330c7f06558e51ecab48d6a4ca2854
Commit:        68bb639a08330c7f06558e51ecab48d6a4ca2854
Parent:        367e4551a1f1ef81f4ed3cc0200247a571af78e8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 31 15:57:30 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 31 15:57:42 2014 +0200

config: fix compile error in config-settings.h if using --disable-dmeventd

  config/config_settings.h:257:102: error: 'DMEVENTD_PATH' undeclared here (not in a function)
---
 lib/config/config_settings.h |    2 +-
 lib/config/defaults.h        |    6 ++++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index dce77b9..932ba2e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -254,7 +254,7 @@ cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_
 cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL)
 cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL)
 cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL)
-cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DMEVENTD_PATH, vsn(2, 2, 73), NULL)
+cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), NULL)
 
 cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL)
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6820def..94b11c0 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -66,6 +66,12 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#ifndef DMEVENTD_PATH
+#define DEFAULT_DMEVENTD_PATH ""
+#else
+#define DEFAULT_DMEVENTD_PATH DMEVENTD_PATH
+#endif
+
 #define DEFAULT_THIN_CHECK_OPTIONS "-q"
 #define DEFAULT_THIN_REPAIR_OPTIONS ""
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0


