From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:18 -0400
Subject: [PATCH 06/20] Add id_format_and_copy() common function and call from _uuid_disp.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting uuid function to allocate memory and call id_write_format.
Call id_format_and_copy from _uuid_disp.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/report.c |    7 +------
 lib/uuid/uuid.c     |   15 +++++++++++++++
 lib/uuid/uuid.h     |    2 ++
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index d0901a5..b8c5d1a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -677,12 +677,7 @@ static int _uuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_po
 {
 	char *repstr = NULL;
 
-	if (!(repstr = dm_pool_alloc(mem, 40))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (!id_write_format((const struct id *) data, repstr, 40))
+	if (!(repstr = id_format_and_copy(mem, (struct id *)data)))
 		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index de3f0cd..e85e852 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -206,3 +206,18 @@ int id_read_format(struct id *id, const char *buffer)
 
 	return id_valid(id);
 }
+
+char *id_format_and_copy(struct dm_pool *mem, const struct id *id)
+{
+	char *repstr = NULL;
+
+	if (!(repstr = dm_pool_alloc(mem, 40))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (!id_write_format(id, repstr, 40))
+		return_NULL;
+
+	return repstr;
+}
diff --git a/lib/uuid/uuid.h b/lib/uuid/uuid.h
index 0029639..5c8382d 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -54,4 +54,6 @@ int id_write_format(const struct id *id, char *buffer, size_t size);
  */
 int id_read_format(struct id *id, const char *buffer);
 
+char *id_format_and_copy(struct dm_pool *mem, const struct id *id);
+
 #endif
-- 
1.7.2.2


