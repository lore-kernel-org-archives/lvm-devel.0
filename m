From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:50 +0000 (UTC)
Subject: master - cleanup: make this error an internal error
Message-ID: <20161123165550.1AAF260F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a04b4bb89ef79ebaf44804f9230f8ee8c652eb7c
Commit:        a04b4bb89ef79ebaf44804f9230f8ee8c652eb7c
Parent:        5fd5cfe06143cc7323efb9b76a4d520cc9442df8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 17:15:10 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:48:01 2016 +0100

cleanup: make this error an internal error

We shouldn't get here with wrong type.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 58be1db..8c8888e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3676,7 +3676,7 @@ int lv_add_mirror_lvs(struct logical_volume *lv,
 	seg = first_seg(lv);
 
 	if (dm_list_size(&lv->segments) != 1 || seg_type(seg, 0) != AREA_LV) {
-		log_error("Mirror layer must be inserted before adding mirrors.");
+		log_error(INTERNAL_ERROR "Mirror layer must be inserted before adding mirrors.");
 		return 0;
 	}
 


