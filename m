From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:46 +0000 (UTC)
Subject: master - coverity: catch unwanted path
Message-ID: <20140512142546.8A2F26030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b95c82fed667b4095b1358ac5697fd43cd61e11
Commit:        8b95c82fed667b4095b1358ac5697fd43cd61e11
Parent:        2e1192f6914ddbe1cf560a02158bdb58584efa26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 9 17:10:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:39 2014 +0200

coverity: catch unwanted path

We validate this path already earlier.
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b47e2d2..2005826 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6140,6 +6140,11 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 
 	if (seg_is_thin_volume(lp)) {
 		/* Ensure all stacked messages are submitted */
+		if (!lp->pool) {
+			log_error(INTERNAL_ERROR "Undefined pool for thin volume segment.");
+			return NULL;
+		}
+
 		if (!(lvl = find_lv_in_vg(vg, lp->pool))) {
 			log_error("Unable to find existing pool LV %s in VG %s.",
 				  lp->pool, vg->name);


