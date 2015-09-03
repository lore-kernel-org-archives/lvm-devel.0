From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:11 +0000 (UTC)
Subject: master - thin: validate mapped size of thin volume
Message-ID: <20150903213611.6C21A60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df110bccbed2bc7f53355fcb16309eb2727ba483
Commit:        df110bccbed2bc7f53355fcb16309eb2727ba483
Parent:        a01eb9c451b136ccb12f3baf6b487604a4f209dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 3 22:52:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

thin: validate mapped size of thin volume

Never show we map more then 100% for a volume.
But show warning when there could be some consistency problems.
---
 lib/thin/thin.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index c5f04f3..7bf7f4e 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -620,6 +620,15 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 		/* Pool allocates whole chunk so round-up to nearest one */
 		csize = first_seg(seg->pool_lv)->chunk_size;
 		csize = ((seg->lv->size + csize - 1) / csize) * csize;
+		if (s->mapped_sectors > csize) {
+			log_warn("WARNING: LV %s maps %s while the size is only %s.",
+				 display_lvname(seg->lv),
+				 display_size(cmd, s->mapped_sectors),
+				 display_size(cmd, csize));
+			/* Don't show nonsense numbers like i.e. 1000% full */
+			s->mapped_sectors = csize;
+		}
+
 		*percent = dm_make_percent(s->mapped_sectors, csize);
 		*total_denominator += csize;
 	} else {


