From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:35 -0500
Subject: master - lvextend: fix resizing volumes of different segtype
Message-ID: <02656.119111116463300255@us-mta-428.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08f36dd093c708f0d4a4edd1fd1d84e9a2316313
Commit:        08f36dd093c708f0d4a4edd1fd1d84e9a2316313
Parent:        3b05fd4d072d94bfead8c2d188ecf704fe57e2a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 11 17:36:58 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

lvextend: fix resizing volumes of different segtype

When resizing 2 volumes like  thin-pool and it's metadata and they
would be of a different type - command would be actually expecting
both LVs being of a same segtype - and would throw an error in
case they are different.

This patch fixes is by setting a new segtype from last segment of
2nd. extented device.

Also it fixes the possible 'percentage' extension setup that
might have been used for 'primary' volume - while the 'secondary'
LV always goes with direct size - as we do not support 'percentage'
setup for them

This affects maily usage of thin-pool where the extension of
thin-pool data size may also lead to extension of metadata size.
---
 lib/metadata/lv_manip.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ae103d3..b4daa56 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5623,6 +5623,8 @@ static struct logical_volume *_lvresize_setup_aux(struct logical_volume *lv,
 	struct lv_segment *mseg = last_seg(lv);
 
 	lp->alloc = lv->alloc;
+	lp->percent = PERCENT_NONE;
+	lp->segtype = mseg->segtype;
 	lp->mirrors = seg_is_mirrored(mseg) ? lv_mirror_count(lv) : 0;
 	lp->resizefs = 0;
 	lp->stripes = lp->mirrors ? mseg->area_count / lp->mirrors : 0;



