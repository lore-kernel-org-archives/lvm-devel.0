From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:04 -0500
Subject: [PATCH 16/21] Add lvm_vg_uuid with test code.
In-Reply-To: <1234153329-2829-16-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-16-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-17-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h              |    1 +
 lib/metadata/metadata.c |   14 ++++++++++++++
 test/api/test.c         |    3 ++-
 3 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index e555291..1c1763b 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -78,6 +78,7 @@ typedef struct logical_volume lv_t;
 const char *lvm_pv_name(const pv_t *pv);
 const char *lvm_vg_name(const vg_t *vg);
 const char *lvm_lv_name(const lv_t *lv);
+const char *lvm_vg_uuid(vg_t *vg);
 
 int lvm_vg_get_attr_list(vg_t *vg, struct dm_list *list);
 int lvm_vg_get_attr_value(vg_t *vg, const char *attr_name,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dcc0156..9405754 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2717,6 +2717,20 @@ const char *lvm_vg_name(const vg_t *vg)
 	return vg->name;
 }
 
+/* FIXME: signedness + null termination problem - export proper uuid type */
+const char *lvm_vg_uuid(vg_t *vg)
+{
+	char *value;
+
+	/* FIXME: leak - this is really bad */
+	if (!(value = dm_pool_zalloc(vg->cmd->mem, sizeof(vg->id.uuid)+1)))
+		return NULL;
+	strncpy(value, vg->id.uuid, sizeof(vg->id.uuid));
+	value[sizeof(vg->id.uuid)] = '\0';
+	
+	return value;
+}
+
 const char *lvm_lv_name(const lv_t *lv)
 {
 	return lv->name;
diff --git a/test/api/test.c b/test/api/test.c
index 681c9a8..08daf30 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -273,7 +273,8 @@ static void _vg_close(char **argv, int argc)
 
 static void _show_one_vg(vg_t *vg)
 {
-	printf("%s: mode = %s\n", lvm_vg_name(vg),
+	printf("%s: uuid = %s, mode = %s\n", lvm_vg_name(vg),
+	       lvm_vg_uuid(vg),
 	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
 	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
 	       "UNKNOWN");
-- 
1.6.0.5


