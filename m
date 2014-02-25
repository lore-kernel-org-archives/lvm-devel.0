From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Feb 2014 10:33:17 +0000 (UTC)
Subject: master - config: use DMEVENTD_PATH for default dmeventd executable config
Message-ID: <20140225103317.45C1E6126A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0b5e51d29d5d1c03b3fd561ced3755383d5f4c3
Commit:        d0b5e51d29d5d1c03b3fd561ced3755383d5f4c3
Parent:        1b566a2152f5b7fcf55f2c148a5fe52d7370666e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 25 11:04:48 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 25 11:32:29 2014 +0100

config: use DMEVENTD_PATH for default dmeventd executable config

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index ae91e2d..f1900b8 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -246,7 +246,7 @@ cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_
 cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL)
 cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL)
 cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL)
-cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, NULL, vsn(2, 2, 73), NULL)
+cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DMEVENTD_PATH, vsn(2, 2, 73), NULL)
 
 cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL)
 


