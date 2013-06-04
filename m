From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:23:46 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: remove unused lvl_idx
Message-ID: <20130604192346.3008F60E4F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e39392daf1de9c61052edc991f30bda352612c9
Commit:        2e39392daf1de9c61052edc991f30bda352612c9
Parent:        4cce09dbdbf1fdb8e6ca985144fdeb181c3a480b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 11 13:48:23 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 12 11:26:31 2013 +0200

cleanup: remove unused lvl_idx

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b1ada5c..43cf14e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1896,7 +1896,7 @@ try_again:
 
 int lv_raid_remove_missing(struct logical_volume *lv)
 {
-	uint32_t s, lvl_idx;
+	uint32_t s;
 	struct lv_segment *seg = first_seg(lv);
 	struct cmd_context *cmd = lv->vg->cmd;
 
@@ -1913,7 +1913,7 @@ int lv_raid_remove_missing(struct logical_volume *lv)
 	 * FIXME: Make sure # of compromised components will not affect RAID
 	 */
 
-	for (s = 0, lvl_idx = 0; s < seg->area_count; s++) {
+	for (s = 0; s < seg->area_count; s++) {
 		if (!(seg_lv(seg, s)->status & PARTIAL_LV) &&
 		    !(seg_metalv(seg, s)->status & PARTIAL_LV))
 			continue;


