From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:22 +0000 (UTC)
Subject: master - libdm: add mangling support for dm_task_set_uuid
Message-ID: <20121010151822.B47232EA7@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a621795a3c011d3e3cf9031f09f2bdfa05d4dc8c
Commit:        a621795a3c011d3e3cf9031f09f2bdfa05d4dc8c
Parent:        12f5c3f726823d13be561645935d0f77c1334e95
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:00:41 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:13 2012 +0200

libdm: add mangling support for dm_task_set_uuid

Also, add a new field to struct dm_task called "mangled_uuid" that
will store mangled form of uuid if it differs from original uuid.
---
 libdm/ioctl/libdm-iface.c   |    5 +++++
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdm-common.c        |   28 ++++++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3166c06..0dd25ef 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -455,6 +455,7 @@ void dm_task_destroy(struct dm_task *dmt)
 	dm_free(dmt->message);
 	dm_free(dmt->geometry);
 	dm_free(dmt->uuid);
+	dm_free(dmt->mangled_uuid);
 	dm_free(dmt);
 }
 
@@ -1317,6 +1318,8 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->type = DM_DEVICE_RESUME;
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
+	dm_free(dmt->mangled_uuid);
+	dmt->mangled_uuid = NULL;
 
 	if (dm_task_run(dmt))
 		return 1;
@@ -1325,6 +1328,8 @@ static int _create_and_load_v4(struct dm_task *dmt)
 	dmt->type = DM_DEVICE_REMOVE;
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
+	dm_free(dmt->mangled_uuid);
+	dmt->mangled_uuid = NULL;
 
 	/*
 	 * Also udev-synchronize "remove" dm task that is a part of this revert!
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index c004d3e..8fc8738 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -69,6 +69,7 @@ struct dm_task {
 	int expected_errno;
 
 	char *uuid;
+	char *mangled_uuid;
 };
 
 struct cmd_data {
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b990ded..b8533ed 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -717,7 +717,35 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 
 int dm_task_set_uuid(struct dm_task *dmt, const char *uuid)
 {
+	char mangled_uuid[DM_UUID_LEN];
+	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
+	int r = 0;
+
 	dm_free(dmt->uuid);
+	dmt->uuid = NULL;
+	dm_free(dmt->mangled_uuid);
+	dmt->mangled_uuid = NULL;
+
+	if (!check_multiple_mangled_string_allowed(uuid, "UUID", mangling_mode))
+		return_0;
+
+	if (mangling_mode != DM_STRING_MANGLING_NONE &&
+	    (r = mangle_string(uuid, "UUID", strlen(uuid), mangled_uuid,
+			       sizeof(mangled_uuid), mangling_mode)) < 0) {
+		log_error("Failed to mangle device uuid \"%s\".", uuid);
+		return 0;
+	}
+
+	if (r) {
+		log_debug("Device uuid mangled [%s]: %s --> %s",
+			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+			  uuid, mangled_uuid);
+
+		if (!(dmt->mangled_uuid = dm_strdup(mangled_uuid))) {
+			log_error("dm_task_set_uuid: dm_strdup(%s) failed", mangled_uuid);
+			return 0;
+		}
+	}
 
 	if (!(dmt->uuid = dm_strdup(uuid))) {
 		log_error("dm_task_set_uuid: strdup(%s) failed", uuid);


