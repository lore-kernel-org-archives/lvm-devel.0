From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:39 -0400
Subject: master - vdo: with created names use vpool
Message-ID: <201807091334.w69DYd6t030662@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b7a57c9ed5187e32394a983e08be3b4a0b19079
Commit:        4b7a57c9ed5187e32394a983e08be3b4a0b19079
Parent:        a8f84f78015326125c4884046014a5b93fded77f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 3 20:14:48 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo: with created names use vpool

When user create vdo-pool - use different automatic name.
So unlike with traditional LVs using  lvol0, lvol1
use vpool0, vpool1...

TODO: apply similar for thin-pool  & cache-pool...
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b731c2a..2dfe994 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8125,8 +8125,8 @@ struct logical_volume *lv_create_single(struct volume_group *vg,
 			/* The VDO segment needs VDO pool which is layer above created striped data LV */
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, SEG_TYPE_NAME_VDO_POOL)))
 				return_NULL;
-
-			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name)))
+			/* Use vpool names for vdo-pool */
+			if (!(lv = _lv_create_an_lv(vg, lp, lp->pool_name ? : "vpool%d")))
 				return_NULL;
 		} else {
 			log_error(INTERNAL_ERROR "Creation of pool for unsupported segment type %s.",


