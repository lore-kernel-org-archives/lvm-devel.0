From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:55 +0100
Subject: [PATCH 08/12] Check for DM_MAX_TYPE_NAME length
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <73bd5ed96f58434b9998794cf17d4c4d11bedaa9.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid creation of target when it's longer then DM_MAX_TYPE_NAME
(noticed by static analyzer where the sp.target_type
might be missing '\0' at the end.)

Before patch:

$> dmsetup create long
0 1000 looooooooooooooooooooooooooong
^D
device-mapper: reload ioctl failed: Invalid argument

After patch:

$> dmsetup create xxx
0 1000 looooooooooooooooooooooooooong
Target type name looooooooooooooooooooooooooong is too long.
Command failed

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |   32 ++++++++++++++++++++------------
 libdm/libdm-common.c      |    3 +--
 2 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index cddd84a..725bd83 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -853,9 +853,14 @@ int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr)
 struct target *create_target(uint64_t start, uint64_t len, const char *type,
 			     const char *params)
 {
-	struct target *t = dm_zalloc(sizeof(*t));
+	struct target *t;
+
+	if (strlen(type) >= DM_MAX_TYPE_NAME) {
+		log_error("Target type name %s is too long.", type);
+		return NULL;
+	}
 
-	if (!t) {
+	if (!(t = dm_zalloc(sizeof(*t)))) {
 		log_error("create_target: malloc(%" PRIsize_t ") failed",
 			  sizeof(*t));
 		return NULL;
@@ -889,19 +894,24 @@ static char *_add_target(struct target *t, char *out, char *end)
 	size_t sp_size = sizeof(struct dm_target_spec);
 	int len;
 
-	out += sp_size;
-	if (out >= end)
-		return_NULL;
+	if (strlen(t->type) >= sizeof(sp.target_type)) {
+		log_error("Target type name %s is too long.", t->type);
+		return NULL;
+	}
 
 	sp.status = 0;
 	sp.sector_start = t->start;
 	sp.length = t->length;
-	strncpy(sp.target_type, t->type, sizeof(sp.target_type));
+	strncpy(sp.target_type, t->type, sizeof(sp.target_type) - 1);
+	sp.target_type[sizeof(sp.target_type) - 1] = '\0';
 
+	out += sp_size;
 	len = strlen(t->params);
 
-	if ((out + len + 1) >= end)
-		return_NULL;
+	if ((out >= end) || (out + len + 1) >= end) {
+		log_error("Ran out of memory building ioctl parameter");
+		return NULL;
+	}
 
 	strcpy(out, t->params);
 	out += len + 1;
@@ -1117,10 +1127,8 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	e = (char *) dmi + len;
 
 	for (t = dmt->head; t; t = t->next)
-		if (!(b = _add_target(t, b, e))) {
-			log_error("Ran out of memory building ioctl parameter");
-			goto bad;
-		}
+		if (!(b = _add_target(t, b, e)))
+			goto_bad;
 
 	if (dmt->newname)
 		strcpy(b, dmt->newname);
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 23539d7..4f438bd 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -407,9 +407,8 @@ int dm_task_add_target(struct dm_task *dmt, uint64_t start, uint64_t size,
 		       const char *ttype, const char *params)
 {
 	struct target *t = create_target(start, size, ttype, params);
-
 	if (!t)
-		return 0;
+		return_0;
 
 	if (!dmt->head)
 		dmt->head = dmt->tail = t;
-- 
1.7.7.3


