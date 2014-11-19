From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Nov 2014 17:58:43 +0000 (UTC)
Subject: master - thin: fix error path
Message-ID: <20141119175844.0338760DF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7985ebead2a69f8139bf4ade0747b2a96f784c4
Commit:        d7985ebead2a69f8139bf4ade0747b2a96f784c4
Parent:        4a52a9212cc5d3ae90196776f28dbfb319002c74
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 19 18:57:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 19 18:58:30 2014 +0100

thin: fix error path

Print pool name and not the origin name.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ca2a706..879cd51 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7085,8 +7085,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				if (thin_pool_was_active < 0)
 					thin_pool_was_active = 0;
 				if (!activate_lv_excl(cmd, pool_lv)) {
-					log_error("Failed to activate thin pool %s/%s.",
-						  origin_lv->vg->name, origin_lv->name);
+					log_error("Failed to activate thin pool %s.",
+						  display_lvname(pool_lv));
 					goto revert_new_lv;
 				}
 				if (!lv_is_active(pool_lv)) {


