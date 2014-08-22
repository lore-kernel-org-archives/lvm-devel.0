From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 22 Aug 2014 18:09:29 +0000 (UTC)
Subject: master - lvcreate: disallow snapshot of cache lv
Message-ID: <20140822180929.788866101B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a67c484fac6daaa3437258072021f122950b7d8f
Commit:        a67c484fac6daaa3437258072021f122950b7d8f
Parent:        0b3d0e79f694ac9dc5a29270b2f791a250980058
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 22 11:32:36 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 22 11:54:49 2014 -0500

lvcreate: disallow snapshot of cache lv

---
 tools/lvcreate.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 541fd51..7870d4f 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -243,6 +243,11 @@ static int _determine_snapshot_type(struct volume_group *vg,
 		return 0;
 	}
 
+	if (lv_is_cache(lvl->lv)) {
+		log_error("Snapshot of cache LV is not yet supported.");
+		return 0;
+	}
+
 	if (!arg_count(vg->cmd, extents_ARG) && !arg_count(vg->cmd, size_ARG)) {
 		if (seg_is_thin(lp)) {
 			if (!(lp->segtype = get_segtype_from_string(vg->cmd, "thin")))


