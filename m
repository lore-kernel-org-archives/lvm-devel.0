From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Nov 2015 18:01:40 +0000 (UTC)
Subject: master - cleanup: do not call vg_read with NULL mda
Message-ID: <20151117180140.30C89600C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=011dd82050fb3225d7ea3c24be5c8dad026117d3
Commit:        011dd82050fb3225d7ea3c24be5c8dad026117d3
Parent:        121341e52c8cb3bf14571cad0c3d90c1ec9d717d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 17 13:23:28 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 17 19:01:25 2015 +0100

cleanup: do not call vg_read with NULL mda

Use 'mda' instead of NULL to quite Coverity warn.
However this code seems to be actually not even possible to hit.
With proper analysis it may possibly be dropped from code to
simplify logic.
---
 lib/cache/lvmetad.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8b5bcfb..d300d39 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1370,9 +1370,10 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	 * can scan further devices.
 	 */
 	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS)) {
+		/* This code seems to be unreachable */
 		if ((mda = (struct metadata_area *)dm_list_first(&baton.fid->metadata_areas_in_use)))
 			baton.vg = mda->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info),
-						     NULL, NULL, NULL, 1);
+						     mda, NULL, NULL, 1);
 	}
 
 	if (!baton.vg)


