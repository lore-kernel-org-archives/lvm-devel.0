From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:54:51 -0500
Subject: master - vdo: fix archived metadata comment
Message-ID: <201901211154.x0LBspKN024387@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f87dd7b12745815c391257afc0b9631c708c2b6c
Commit:        f87dd7b12745815c391257afc0b9631c708c2b6c
Parent:        0d142f65141d591430ced6a7a7fcccb4d2198d28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 14 16:21:02 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:37:52 2019 +0100

vdo: fix archived metadata comment

lvm uses 'minimum_io_size' name to exactly match  VDO naming here,
however in all common cases  _size  is using 'sector/512b' unit.
But in this case the value is in bytes and can have only 2 values:
either 512 or 4096.

It's probably not worth to rename it internaly, so we can just
drop comment - instead of using 1 or 8.

Thought let's think about it....
---
 WHATS_NEW     |    1 +
 lib/vdo/vdo.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1187fb4..5bb5797 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Drop misleadning comment for metadata minimum_io_size for VDO segment.
   Add device hints to reduce scanning.
   Introduce LVM_SUPPRESS_SYSLOG to suppress syslog usage by generator.
   Fix generator quering lvmconfig unpresent config option.
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index c34eb93..ed051fc 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -308,7 +308,7 @@ static int _vdo_pool_text_export(const struct lv_segment *seg, struct formatter
 	if (vtp->use_metadata_hints)
 		outf(f, "use_metadata_hints = 1");
 
-	outsize(f, vtp->minimum_io_size, "minimum_io_size = %u", vtp->minimum_io_size);
+	outf(f, "minimum_io_size = %u", vtp->minimum_io_size);
 
 	outsize(f, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024),
 		"block_map_cache_size_mb = %u", vtp->block_map_cache_size_mb);


