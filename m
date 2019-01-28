From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jan 2019 16:40:38 -0500
Subject: master - cache: select chunk size as power of 2
Message-ID: <201901282140.x0SLecLU002408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58ad831c72b024233d91980f2269d0a26101ff99
Commit:        58ad831c72b024233d91980f2269d0a26101ff99
Parent:        cbf62b9262d493a5df9ab5a57e68395465d4701a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 28 20:08:49 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 28 22:17:14 2019 +0100

cache: select chunk size as power of 2

When cache chunk size is not configured, and left for lvm deduction,
select the value which is power-of-2.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 06848ea..90739c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Cache selects power-of-2 chunk size by default.
   Support reszing for VDOPoolLV and VDOLV.
   Improve -lXXX%VG modifier which improves cache segment estimation.
   Ensure migration_threshold for cache is at least 8 chunks.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 656e49d..ee2a5c5 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -215,9 +215,12 @@ int update_cache_pool_params(struct cmd_context *cmd,
 
 	if (!*chunk_size) {
 		if (!(*chunk_size = find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG,
-							 profile) * 2))
+							 profile) * 2)) {
 			*chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd,
 										       profile);
+			/* Use power-of-2 for min chunk size when unspecified */
+			min_chunk_size = 1 << (32 - clz(min_chunk_size - 1));
+		}
 		if (*chunk_size < min_chunk_size) {
 			/*
 			 * When using more then 'standard' default,


