From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Sep 2010 16:13:01 -0400
Subject: [PATCH 04/12] Call id_format_and_copy from _uuid_disp.
In-Reply-To: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284063189-4908-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/report.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index b7612a1..940ee25 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -677,13 +677,8 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 {
 	char *repstr = NULL;
 
-	if (!(repstr = dm_pool_alloc(mem, 40))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = id_format_and_copy(mem, (struct id *)data)))
 		return 0;
-	}
-
-	if (!id_write_format((const struct id *) data, repstr, 40))
-		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
-- 
1.7.2.1


