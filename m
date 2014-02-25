From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 08:44:48 +0000 (UTC)
Subject: master - mirror: look for mirror seg only in mirror LV
Message-ID: <20140225084448.4A3FC6113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=962af71b7635ead2bc4449a1dd0bd4d4a2b46b07
Commit:        962af71b7635ead2bc4449a1dd0bd4d4a2b46b07
Parent:        b84797be3278e2ec232b8de7293dcac665d980f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 09:34:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 09:34:02 2014 +0100

mirror: look for mirror seg only in mirror LV

Find mirror seg only in MIRROR_IMAGE.
(in-release update)
---
 lib/metadata/lv.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 2f2b7cb..4549f03 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -396,11 +396,11 @@ static int _lv_mimage_in_sync(const struct logical_volume *lv)
 	struct lv_segment *seg = first_seg(lv);
 	struct lv_segment *mirror_seg;
 
-	if (seg)
-		mirror_seg = find_mirror_seg(seg);
-
-	if (!(lv->status & MIRROR_IMAGE) || !seg || !mirror_seg)
-		return_0;
+	if (!(lv->status & MIRROR_IMAGE) || !seg ||
+	    !(mirror_seg = find_mirror_seg(seg))) {
+		log_error(INTERNAL_ERROR "Cannot find mirror segment.");
+		return 0;
+	}
 
 	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
 			       NULL))


