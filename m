From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Jun 2013 12:52:00 +0000 (UTC)
Subject: master - cleanup: tab
Message-ID: <20130613125200.9F4E160F41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=036d4f2982e8b1c34a7594307c6d2ae98cd36237
Commit:        036d4f2982e8b1c34a7594307c6d2ae98cd36237
Parent:        fe22089edff17158e6d9264cd671395b2ad6e060
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 13 14:10:49 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 13 14:51:02 2013 +0200

cleanup: tab

---
 tools/vgsplit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index de41df7..6beaf34 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -181,7 +181,7 @@ static int _move_mirrors(struct volume_group *vg_from,
 		seg_in = 0;
 		for (s = 0; s < seg->area_count; s++)
 			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
-			    seg_in++;
+				seg_in++;
 
 		log_in = !seg->log_lv;
 		if (seg->log_lv) {


