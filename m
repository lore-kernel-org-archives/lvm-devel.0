From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:27 +0000 (UTC)
Subject: master - libdm: unmangle dm UUIDs on dm ioctl return
Message-ID: <20121010151827.39C962EA7@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8dccbae35e6a26fbc736d215de8e0538773de5e0
Commit:        8dccbae35e6a26fbc736d215de8e0538773de5e0
Parent:        7e71ecbaf6137fa6b6e3ca5c25c090369fe69dd4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:01:42 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:15 2012 +0200

libdm: unmangle dm UUIDs on dm ioctl return

---
 libdm/ioctl/libdm-iface.c |   39 +++++++++++++++++++++++++++++----------
 1 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 04e458c..ac3442e 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1571,44 +1571,48 @@ static const char *_sanitise_message(char *message)
 	return sanitised_message;
 }
 
-static int _do_dm_ioctl_unmangle_name(char *name)
+static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
+					char *buf, size_t buf_size,
+					dm_string_mangling_t mode)
 {
-	dm_string_mangling_t mode = dm_get_name_mangling_mode();
-	char buf[DM_NAME_LEN];
 	int r;
 
 	if (mode == DM_STRING_MANGLING_NONE)
 		return 1;
 
-	if (!check_multiple_mangled_string_allowed(name, "name", mode))
+	if (!check_multiple_mangled_string_allowed(str, str_name, mode))
 		return_0;
 
-	if ((r = unmangle_string(name, "name", DM_NAME_LEN, buf, sizeof(buf), mode)) < 0) {
-		log_debug("_do_dm_ioctl_unmangle_name: failed to "
-			  "unmangle \"%s\"", name);
+	if ((r = unmangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0) {
+		log_debug("_do_dm_ioctl_unmangle_string: failed to "
+			  "unmangle %s \"%s\"", str_name, str);
 		return 0;
 	} else if (r)
-		memcpy(name, buf, strlen(buf) + 1);
+		memcpy(str, buf, strlen(buf) + 1);
 
 	return 1;
 }
 
 static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 {
+	char buf[DM_NAME_LEN];
 	struct dm_names *names;
 	unsigned next = 0;
 	char *name;
 	int r = 1;
 
 	if ((name = dmi->name))
-		r = _do_dm_ioctl_unmangle_name(name);
+		r = _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
+						 dm_get_name_mangling_mode());
 
 	if (type == DM_DEVICE_LIST &&
 	    ((names = ((struct dm_names *) ((char *)dmi + dmi->data_start)))) &&
 	    names->dev) {
 		do {
 			names = (struct dm_names *)((char *) names + next);
-			r = _do_dm_ioctl_unmangle_name(names->name);
+			r = _do_dm_ioctl_unmangle_string(names->name, "name",
+							 buf, sizeof(buf),
+							 dm_get_name_mangling_mode());
 			next = names->next;
 		} while (next);
 	}
@@ -1616,6 +1620,18 @@ static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 	return r;
 }
 
+static int _dm_ioctl_unmangle_uuids(int type, struct dm_ioctl *dmi)
+{
+	char buf[DM_UUID_LEN];
+	char *uuid = dmi->uuid;
+
+	if (uuid)
+		return _do_dm_ioctl_unmangle_string(uuid, "UUID", buf, sizeof(buf),
+						    dm_get_name_mangling_mode());
+
+	return 1;
+}
+
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned buffer_repeat_count,
 				     unsigned retry_repeat_count,
@@ -1746,6 +1762,9 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	if (!_dm_ioctl_unmangle_names(dmt->type, dmi))
 		goto error;
 
+	if (!_dm_ioctl_unmangle_uuids(dmt->type, dmi))
+		goto error;
+
 #else /* Userspace alternative for testing */
 #endif
 	return dmi;


