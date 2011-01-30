From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:42 +0100
Subject: [PATCH 19/24] Use cleaner const * pointer
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <410ff935ee9f2456283a2c801aeafe7d3ce2aa20.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now it's warning free -
Const cast in _string_disp() is not even needed,
but it's more readable conversion.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/report.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 136ad4c..f470840 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -44,7 +44,7 @@ static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char * const *) data);
 }
 
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
@@ -307,10 +307,8 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	char *repstr, *lvname;
 	size_t len;
 
-	if (lv_is_visible(lv)) {
-		repstr = lv->name;
-		return dm_report_field_string(rh, field, (const char **) &repstr);
-	}
+	if (lv_is_visible(lv))
+		return dm_report_field_string(rh, field, &lv->name);
 
 	len = strlen(lv->name) + 3;
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
-- 
1.7.3.5


