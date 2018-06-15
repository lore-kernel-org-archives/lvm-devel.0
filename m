From: David Teigland <teigland@sourceware.org>
Date: Fri, 15 Jun 2018 15:17:09 -0400
Subject: master - report: show empty lock_type for none
Message-ID: <201806151917.w5FJH9EN013796@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccab4a1994f4218810f1a6152cf6c71caa00977e
Commit:        ccab4a1994f4218810f1a6152cf6c71caa00977e
Parent:        328303d4d45b4e9480cc806ef84e843e2176f584
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 15 14:14:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 15 14:14:39 2018 -0500

report: show empty lock_type for none

Sometimes lock_type would be displayed as "none"
(after changing it) and sometimes as empty.
Make it consistently empty.
---
 lib/report/report.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 8039820..369f47c 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2855,8 +2855,14 @@ static int _vglocktype_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
+	const char *locktype;
 
-	return _field_string(rh, field, vg->lock_type ? : "");
+	if (!vg->lock_type || !strcmp(vg->lock_type, "none"))
+		locktype = "";
+	else
+		locktype = vg->lock_type;
+
+	return _field_string(rh, field, locktype);
 }
 
 static int _vglockargs_disp(struct dm_report *rh, struct dm_pool *mem,


