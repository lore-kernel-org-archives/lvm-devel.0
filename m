From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:31 -0400
Subject: master - exported_symbols: comment old symbols
Message-ID: <201908091058.x79AwVFw031551@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f5ea9e61acf56aa244715570710ba1e229a77cd
Commit:        2f5ea9e61acf56aa244715570710ba1e229a77cd
Parent:        f2489d9dda78a9976b9655cd82efaa7ef6615e91
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 30 15:31:51 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

exported_symbols: comment old symbols

Fix versioning for updated symbols dm_stats_create_region
and dm_stats_create_region.

Only the latest symbol should have global entry.

Since I'm not sure what is currenlty the best option for
old symbols - we added support for easy commenting of them
(so we do not lose information when the symbol appeared
for the first time.)

Note: some old already deleted symbols should have been
restored as comments.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.DM_1_02_106 |    2 +-
 libdm/.exported_symbols.DM_1_02_129 |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4ea3ed5..2c0c7ec 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.165 - 
 =================================
+  Fix versioning of dm_stats_create_region and dm_stats_create_region.
 
 Version 1.02.163 - 15th June 2019
 =================================
diff --git a/libdm/.exported_symbols.DM_1_02_106 b/libdm/.exported_symbols.DM_1_02_106
index 0bec544..88bba02 100644
--- a/libdm/.exported_symbols.DM_1_02_106
+++ b/libdm/.exported_symbols.DM_1_02_106
@@ -1,5 +1,5 @@
 dm_message_supports_precise_timestamps
-dm_stats_create_region
+#dm_stats_create_region
 dm_stats_driver_supports_precise
 dm_stats_get_current_region_precise_timestamps
 dm_stats_get_region_precise_timestamps
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
index 88d3f1b..a5133dd 100644
--- a/libdm/.exported_symbols.DM_1_02_129
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -1,4 +1,4 @@
-dm_bitset_parse_list
+#dm_bitset_parse_list
 dm_stats_create_group
 dm_stats_current_object_type
 dm_stats_delete_group


