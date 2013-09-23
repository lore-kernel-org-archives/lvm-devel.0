From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:17 +0000 (UTC)
Subject: master - cleanup: add log_error error path messages
Message-ID: <20130923101617.791E560793@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b4bfca219b47679da846a1750631fc440426143
Commit:        9b4bfca219b47679da846a1750631fc440426143
Parent:        d2d61955a303d73d1a97b80f3a010711eac846d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 23 09:59:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

cleanup: add log_error error path messages

---
 lib/report/report.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 73e72f4..95525d8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1155,14 +1155,13 @@ static int _lvtime_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr;
 	uint64_t *sortval;
 
-	if (!(sortval = dm_pool_zalloc(mem, sizeof(uint64_t)))) {
-		log_error("Failed to allocate sortval.");
+	if (!(repstr = lv_time_dup(mem, lv)) ||
+	    !(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
+		log_error("Failed to allocate buffer for time.");
 		return 0;
 	}
 
 	*sortval = lv->timestamp;
-	if (!(repstr = lv_time_dup(mem, lv)))
-		return_0;
 
 	dm_report_field_set_value(field, repstr, sortval);
 
@@ -1176,8 +1175,10 @@ static int _lvhost_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr;
 
-	if (!(repstr = lv_host_dup(mem, lv)))
-		return_0;
+	if (!(repstr = lv_host_dup(mem, lv))) {
+		log_error("Failed to allocate buffer for host.");
+		return 0;
+	}
 
 	dm_report_field_set_value(field, repstr, repstr);
 
@@ -1190,8 +1191,10 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	char *repstr;
 
-	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data)))
-		return_0;
+	if (!(repstr = lv_active_dup(mem, (const struct logical_volume *) data))) {
+		log_error("Failed to allocate buffer for active.");
+		return 0;
+	}
 
 	dm_report_field_set_value(field, repstr, NULL);
 


