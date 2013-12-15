From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 15 Dec 2013 16:19:15 +0000 (UTC)
Subject: master - pvscan --cache: Error out on pool-format VGs for now.
Message-ID: <20131215161915.C6FC761097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd3edb2566189e1e3e016933e397a58a90bc81ea
Commit:        bd3edb2566189e1e3e016933e397a58a90bc81ea
Parent:        97fbbbc150cdaea359370912a7b5a9a546490e98
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 16:31:35 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Dec 15 16:44:47 2013 +0100

pvscan --cache: Error out on pool-format VGs for now.

---
 lib/cache/lvmetad.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1ead9f8..a2ebefb 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,6 +20,8 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
+#include "format_pool.h" // for FMT_POOL_NAME
+#include "format1.h" // for FMT_LVM1_NAME
 #include "crc.h"
 
 static daemon_handle _lvmetad;
@@ -904,6 +906,13 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
+	if (lvmcache_fmt(info) == get_format_by_name(cmd, FMT_POOL_NAME)) {
+		log_error("WARNING: Ignoring old GFS pool metadata on device %s "
+			  "when using lvmetad", dev_name(dev));
+		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+		return 0;
+	}
+
 	/* LVM1 VGs have no MDAs. */
 	if (!baton.vg && lvmcache_fmt(info) == get_format_by_name(cmd, "lvm1"))
 		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->


