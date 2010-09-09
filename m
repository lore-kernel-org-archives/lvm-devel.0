From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Sep 2010 16:13:00 -0400
Subject: [PATCH 03/12] Add id_format_and_copy() uuid function to allocate and format a uuid.
In-Reply-To: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284063189-4908-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting uuid function to allocate memory and call id_write_format.
Will be used from reporting functions as well as property functions.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/uuid/uuid.c |   15 +++++++++++++++
 lib/uuid/uuid.h |    2 ++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index de3f0cd..6608473 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -206,3 +206,18 @@ int id_read_format(struct id *id, const char *buffer)
 
 	return id_valid(id);
 }
+
+char *id_format_and_copy(struct dm_pool *mem, struct id *id)
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
index 0029639..6c1169a 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -54,4 +54,6 @@ int id_write_format(const struct id *id, char *buffer, size_t size);
  */
 int id_read_format(struct id *id, const char *buffer);
 
+char *id_format_and_copy(struct dm_pool *mem, struct id *id);
+
 #endif
-- 
1.7.2.1


