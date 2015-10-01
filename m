From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  1 Oct 2015 13:03:57 +0000 (UTC)
Subject: master - alloc: fix update or area_len
Message-ID: <20151001130357.9700860331@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a139275eca4fadca4a456fd27e8b2ba30d7d2c02
Commit:        a139275eca4fadca4a456fd27e8b2ba30d7d2c02
Parent:        efcb3bbc8d2ebcc39031cc0d7b446daf864d281e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 1 14:59:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 1 15:02:49 2015 +0200

alloc: fix update or area_len

Commit: 192d9ad97769f2c16f3ebe67e51cfb287e67f67c
changed logic for area_len formula - so it returns
different values.

Placing () to restore previous behaviour and make it
explicit.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 02a43b7..48d7d34 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1932,7 +1932,7 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 		*max_seg_len = remaining_seg_len;
 
 	area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
-	area_len = remaining_seg_len / (area_multiple ? : 1);
+	area_len = (remaining_seg_len / area_multiple) ? : 1;
 
 	/* For striped mirrors, all the areas are counted, through the mirror layer */
 	if (top_level_area_index == -1)


