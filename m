From: Lidong Zhong <lzhong@suse.com>
Date: Sat, 10 Oct 2015 18:39:12 +0800
Subject: [PATCH] lvcreate: support --force option
Message-ID: <1444473552-14906-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The option is supported in the logic of lvcreate but is omitted in
commands.h.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 WHATS_NEW        | 1 +
 tools/commands.h | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9af759e..274af43 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Make lvcreate support --force option
   Cleanup vgimportclone script and remove dependency on awk, grep, cut and tr.
   Add vg_missing_pv_count report field to report number of missing PVs in a VG.
   Properly identify internal LV holding sanlock locks within lv_role field.
diff --git a/tools/commands.h b/tools/commands.h
index 92d13fd..7695498 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -311,6 +311,7 @@ xx(lvcreate,
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
    "\t[--errorwhenfull {y|n}]\n"
    "\t[--ignoremonitoring]\n"
@@ -360,6 +361,7 @@ xx(lvcreate,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
+   "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
@@ -386,7 +388,7 @@ xx(lvcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    cache_ARG, cachemode_ARG, cachepool_ARG, cachepolicy_ARG, cachesettings_ARG,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, errorwhenfull_ARG,
-   extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
+   extents_ARG, force_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
    metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
    minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
    noudevsync_ARG, permission_ARG, persistent_ARG,
-- 
1.8.1.4


