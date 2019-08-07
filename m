From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 7 Aug 2019 09:29:27 -0400
Subject: stable-2.02 - exported_symbols: comment old symbols
Message-ID: <201908071329.x77DTRSv018637@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a3e1ac7407dff9e53c5efea179a5620ad13f8f3
Commit:        4a3e1ac7407dff9e53c5efea179a5620ad13f8f3
Parent:        f39141ebc1aa7f4eda302530ccf866e6954dd077
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 30 15:31:51 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 7 15:28:55 2019 +0200

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
index 8c78724..718d174 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.160 - 
 ================================
+  Fix versioning of dm_stats_create_region and dm_stats_create_region.
   Parsing of cache status understand no_discard_passdown.
 
 Version 1.02.158 - 13th May 2019
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


