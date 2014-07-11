From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 11 Jul 2014 09:58:21 +0000 (UTC)
Subject: master - report: display 'unknown' value for lv_active_remotely field if the LV is also active locally
Message-ID: <20140711095821.1AD0D60EBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd5912762b4815deb7a58fc4c5971801888e0ed3
Commit:        fd5912762b4815deb7a58fc4c5971801888e0ed3
Parent:        c9ae21798e1fa94e56c0f07ece1527377cbf1623
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 11 11:56:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 11 11:56:50 2014 +0200

report: display 'unknown' value for lv_active_remotely field if the LV is also active locally

Currently, we can't determine whether the LV is active remotely
or not in that case.
---
 lib/report/report.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index e9f379a..91dfac0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1478,7 +1478,28 @@ static int _lvactiveremotely_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (vg_is_clustered(lv->vg)) {
 		lv = lv_lock_holder(lv);
-		active_remotely = lv_is_active_but_not_locally(lv);
+		/* FIXME: It seems we have no way to get this info correctly
+		 * 	  with current interface - we'd need to check number
+		 * 	  of responses from the cluster:
+		 * 	    - if number of nodes that responded == 1
+		 * 	    - and LV is active on local node
+		 * 	  ..then we may say that LV is *not* active remotely.
+		 *
+		 * 	  Otherwise ((responses > 1 && LV active locally) ||
+		 * 	  (responses == 1 && LV not active locally)), it's
+		 * 	  active remotely.
+		 *
+		 * 	  We have this info, but hidden underneath the
+		 * 	  locking interface (locking_type.query_resource fn).
+		 *
+		 * 	  For now, let's use 'unknown' for remote status if
+		 * 	  the LV is found active locally until we find a way to
+		 * 	  smuggle the proper information out of the interface.
+		 */
+		if (lv_is_active_locally(lv))
+			return _binary_undef_disp(rh, mem, field, private);
+		else
+			active_remotely = lv_is_active_but_not_locally(lv);
 	} else
 		active_remotely = 0;
 


