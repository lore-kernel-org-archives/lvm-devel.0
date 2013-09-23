From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:19 +0000 (UTC)
Subject: master - cleanup: drop unused report parameter
Message-ID: <20130923101619.9022D606F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b33b618fc8e83a033d91814facd0312c84597372
Commit:        b33b618fc8e83a033d91814facd0312c84597372
Parent:        9b4bfca219b47679da846a1750631fc440426143
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 11:01:46 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: drop unused report parameter

Do not pass unused dm_report pointer.
---
 lib/report/report.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 95525d8..540181a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1035,8 +1035,8 @@ static int _raidmaxrecoveryrate_disp(struct dm_report *rh __attribute__((unused)
 				      &first_seg(lv)->max_recovery_rate);
 }
 
-static int _dtpercent_disp(int metadata, struct dm_report *rh,
-			   struct dm_pool *mem,
+/* Called only with lv_is_thin_pool/volume */
+static int _dtpercent_disp(int metadata, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
@@ -1091,7 +1091,7 @@ static int _datapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 		return _snpercent_disp(rh, mem, field, data, private);
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
-		return _dtpercent_disp(0, rh, mem, field, data, private);
+		return _dtpercent_disp(0, mem, field, data, private);
 
 	dm_report_field_set_value(field, "", NULL);
 
@@ -1105,7 +1105,7 @@ static int _metadatapercent_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv_is_thin_pool(lv))
-		return _dtpercent_disp(1, rh, mem, field, data, private);
+		return _dtpercent_disp(1, mem, field, data, private);
 
 	dm_report_field_set_value(field, "", NULL);
 


