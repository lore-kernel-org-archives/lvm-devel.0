From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 14:02:28 +0000 (UTC)
Subject: master - dev_manager: only support status for cache segment at the moment
Message-ID: <20141111140228.C2F8C6024E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9704515c1e22ff0ebaec16572d1c51d954259da5
Commit:        9704515c1e22ff0ebaec16572d1c51d954259da5
Parent:        8121074fda126cc6c0df05fba066cc9365e00255
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 11 14:55:58 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 15:02:21 2014 +0100

dev_manager: only support status for cache segment at the moment

When getting status for LV segment types, we need to be sure
that proper segment is selected for the status ioctl.

When reporting fields that require status ioctl,
the "_choose_lv_segment_for_status_report" fn in tools/reporter.c
must be completed properly to choose the proper segment for all
the LV types (at the moment, it just takes the first LV segment
by default).

This works fine with cache LVs surely. The other segment types
need more auditing. We use this status ioctl only for cache status
fields at the moment only, so restrict it to the cache only.

Once the _choose_lv_segment_for_status_report is completed
properly, release the restriction in _get_segment_status_from_target_params.
---
 lib/activate/dev_manager.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4351bc9..a392387 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -112,10 +112,14 @@ static int _get_segment_status_from_target_params(const char *target_name,
 {
 	struct segment_type *segtype;
 
-	/* FIXME: linear is also represented as striped with stripe count 1.
-		  We're not reporting linear or striped status anyway, so
-		  just skip the error here till this is properly resolved.*/
-	if (!strcmp(target_name, "linear") || !strcmp(target_name, "striped"))
+	/*
+	 * TODO: Add support for other segment types too!
+	 * The segment to report status for must be properly
+	 * selected for all the other types - mainly make sure
+	 * linear/striped, old snapshots and raids have proper
+	 * segment selected for status!
+	 */
+	if (strcmp(target_name, "cache"))
 		return 1;
 
 	segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name);


