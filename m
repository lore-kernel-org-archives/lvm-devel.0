From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 15 Dec 2013 16:19:17 +0000 (UTC)
Subject: master - pvscan --cache: Use FMT_LVM1_NAME instead of hardcoded "lvm1".
Message-ID: <20131215161917.DF66F61097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18afca5ddded15c528a88a11fe1ea29c8a29cbcd
Commit:        18afca5ddded15c528a88a11fe1ea29c8a29cbcd
Parent:        bd3edb2566189e1e3e016933e397a58a90bc81ea
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Dec 15 16:37:03 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Dec 15 16:44:47 2013 +0100

pvscan --cache: Use FMT_LVM1_NAME instead of hardcoded "lvm1".

---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a2ebefb..65ed520 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -914,7 +914,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	}
 
 	/* LVM1 VGs have no MDAs. */
-	if (!baton.vg && lvmcache_fmt(info) == get_format_by_name(cmd, "lvm1"))
+	if (!baton.vg && lvmcache_fmt(info) == get_format_by_name(cmd, FMT_LVM1_NAME))
 		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->
 			ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, 0);
 


