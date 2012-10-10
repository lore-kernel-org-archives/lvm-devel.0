From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:31 +0000 (UTC)
Subject: master - dmsetup: add mangled/unmangled_uuid to for info -c
Message-ID: <20121010151831.D4C9C2EA7@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=788b7a6a2b6c20f7dddda3b90cd4dd5c60b1e1f5
Commit:        788b7a6a2b6c20f7dddda3b90cd4dd5c60b1e1f5
Parent:        842167eb17b21e5fada08fd3a4beafd96a5b4021
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:02:59 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:15 2012 +0200

dmsetup: add mangled/unmangled_uuid to for info -c

Following the same logic already used for name mangling.
---
 tools/dmsetup.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0ac970f..8d24293 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2319,6 +2319,38 @@ static int _dm_uuid_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, &uuid);
 }
 
+static int _dm_mangled_uuid_disp(struct dm_report *rh,
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct dm_report_field *field,
+				 const void *data, void *private __attribute__((unused)))
+{
+	char *uuid;
+	int r = 0;
+
+	if ((uuid = dm_task_get_uuid_mangled((const struct dm_task *) data))) {
+		r = dm_report_field_string(rh, field, (const char * const *) &uuid);
+		dm_free(uuid);
+	}
+
+	return r;
+}
+
+static int _dm_unmangled_uuid_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute__((unused)),
+				   struct dm_report_field *field,
+				   const void *data, void *private __attribute__((unused)))
+{
+	char *uuid;
+	int r = 0;
+
+	if ((uuid = dm_task_get_uuid_unmangled((const struct dm_task *) data))) {
+		r = dm_report_field_string(rh, field, (const char * const *) &uuid);
+		dm_free(uuid);
+	}
+
+	return r;
+}
+
 static int _dm_read_ahead_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -2740,6 +2772,8 @@ FIELD_F(TASK, STR, "Name", 16, dm_name, "name", "Name of mapped device.")
 FIELD_F(TASK, STR, "MangledName", 16, dm_mangled_name, "mangled_name", "Mangled name of mapped device.")
 FIELD_F(TASK, STR, "UnmangledName", 16, dm_unmangled_name, "unmangled_name", "Unmangled name of mapped device.")
 FIELD_F(TASK, STR, "UUID", 32, dm_uuid, "uuid", "Unique (optional) identifier for mapped device.")
+FIELD_F(TASK, STR, "MangledUUID", 32, dm_mangled_uuid, "mangled_uuid", "Mangled unique (optional) identifier for mapped device.")
+FIELD_F(TASK, STR, "UnmangledUUID", 32, dm_unmangled_uuid, "unmangled_uuid", "Unmangled unique (optional) identifier for mapped device.")
 
 /* FIXME Next one should be INFO */
 FIELD_F(TASK, NUM, "RAhead", 6, dm_read_ahead, "read_ahead", "Read ahead in sectors.")


