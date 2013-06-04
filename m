From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:52 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: use last_seg
Message-ID: <20130604192652.176F360FCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58a2e5e2df4049108b1ba0fe970fd88eba9a3290
Commit:        58a2e5e2df4049108b1ba0fe970fd88eba9a3290
Parent:        8cbacd2474b288a581274dba9b623ec2e9ac9d28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 22 15:04:51 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:28:32 2013 +0200

cleanup: use last_seg

Use function to obtain last segment type.
---
 tools/lvresize.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index e44fd82..b679bf9 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -558,9 +558,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	seg_size = lp->extents - lv->le_count;
 
 	/* Use segment type of last segment */
-	dm_list_iterate_items(seg, &lv->segments) {
-		lp->segtype = seg->segtype;
-	}
+	lp->segtype = last_seg(lv)->segtype;
 
 	/* FIXME Support LVs with mixed segment types */
 	if (lp->segtype != get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,


