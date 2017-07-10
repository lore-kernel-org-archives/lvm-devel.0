From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:59:45 -0400
Subject: master - comment: update
Message-ID: <201707101259.v6ACxjxR027851@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4c943710059e51b3730fea385b7bd8ef34beecb2
Commit:        4c943710059e51b3730fea385b7bd8ef34beecb2
Parent:        d23a475c98fae1a24111a0b4667bdaf5166ccde2
Author:        Eric Ren <zren@suse.com>
AuthorDate:    Sun Jul 9 01:15:49 2017 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:58:01 2017 +0200

comment: update

Use 'is' for both forms.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fbe0aed..0b90705 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7310,7 +7310,7 @@ static int _vg_check_features(struct volume_group *vg,
  * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
  * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
  *   If lp->activate is AY*, activate it.
- *   If lp->activate was AN* and the pool was originally inactive, deactivate it.
+ *   If lp->activate is AN* and the pool was originally not active, deactivate it.
  */
 static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 					       struct lvcreate_params *lp,


