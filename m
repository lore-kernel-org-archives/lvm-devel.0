From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:17 +0200
Subject: [PATCH 6/6] const fixes
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <10df4c198f9e496c5984b90884ff1b664beb2c18.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When recent update dm_report_field_string() API call to accept
completely const object - we no longer need loose const here
and keep it forwarding.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/dmsetup.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5455369..362d7e7 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2456,7 +2456,7 @@ static int _dm_subsystem_disp(struct dm_report *rh,
 			       struct dm_report_field *field, const void *data,
 			       void *private __attribute__((unused)))
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_vg_name_disp(struct dm_report *rh,
@@ -2465,7 +2465,7 @@ static int _dm_vg_name_disp(struct dm_report *rh,
 			     void *private __attribute__((unused)))
 {
 
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_lv_name_disp(struct dm_report *rh,
@@ -2474,7 +2474,7 @@ static int _dm_lv_name_disp(struct dm_report *rh,
 			     void *private __attribute__((unused)))
 
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static int _dm_lv_layer_name_disp(struct dm_report *rh,
@@ -2483,7 +2483,7 @@ static int _dm_lv_layer_name_disp(struct dm_report *rh,
 				   void *private __attribute__((unused)))
 
 {
-	return dm_report_field_string(rh, field, (const char **) data);
+	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
 static void *_task_get_obj(void *obj)
-- 
1.7.4.1


