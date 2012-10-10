From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:34 +0000 (UTC)
Subject: master - dmsetup: also apply 'mangle' command for UUIDs
Message-ID: <20121010151834.30E56335B@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=470d1a2f5459bbbf82effb70b83a86329a170f85
Commit:        470d1a2f5459bbbf82effb70b83a86329a170f85
Parent:        788b7a6a2b6c20f7dddda3b90cd4dd5c60b1e1f5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:03:47 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:15 2012 +0200

dmsetup: also apply 'mangle' command for UUIDs

Compared to names, UUIDs can't be renamed once they are created
for a device. The 'mangle' command will just issue an error message
about a need for manual intervention in this case - reactivating the
device (remove + create) does the job as the defualt mangling mode
used is "auto" and that will assign a correct mangled form the UUID.
---
 tools/dmsetup.c |   41 +++++++++++++++++++++++++++++++++--------
 1 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8d24293..196c170 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2943,8 +2943,8 @@ static int _ls(CMD_ARGS)
 
 static int _mangle(CMD_ARGS)
 {
-	char *name;
-	char *new_name = NULL;
+	const char *name, *uuid;
+	char *new_name = NULL, *new_uuid = NULL;
 	struct dm_task *dmt;
 	struct dm_info info;
 	int r = 0;
@@ -2973,25 +2973,49 @@ static int _mangle(CMD_ARGS)
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
 		goto out;
 
+	uuid = dm_task_get_uuid(dmt);
+
 	target_format = _switches[MANGLENAME_ARG] ? _int_args[MANGLENAME_ARG]
 						  : DEFAULT_DM_NAME_MANGLING;
 
-	if (target_format == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
-		log_error("The name \"%s\" seems to be mangled more than once. "
-			  "Manual intervention required to rename the device.", name);
-		goto out;
+	if (target_format == DM_STRING_MANGLING_AUTO) {
+		if (strstr(name, "\\x5cx")) {
+			log_error("The name \"%s\" seems to be mangled more than once. "
+				  "Manual intervention required to rename the device.", name);
+			goto out;
+		}
+		if (strstr(uuid, "\\x5cx")) {
+			log_error("The UUID \"%s\" seems to be mangled more than once. "
+				  "Manual intervention required to correct the device UUID.", uuid);
+			goto out;
+		}
 	}
 
 	if (target_format == DM_STRING_MANGLING_NONE) {
 		if (!(new_name = dm_task_get_name_unmangled(dmt)))
 			goto out;
+		if (!(new_uuid = dm_task_get_uuid_unmangled(dmt)))
+			goto out;
 	}
-	else if (!(new_name = dm_task_get_name_mangled(dmt)))
+	else {
+		if (!(new_name = dm_task_get_name_mangled(dmt)))
+			goto out;
+		if (!(new_uuid = dm_task_get_uuid_mangled(dmt)))
+			goto out;
+	}
+
+	/* We can't rename the UUID, the device must be reactivated manually. */
+	if (strcmp(uuid, new_uuid)) {
+		log_error("%s: %s: UUID in incorrect form. ", name, uuid);
+		log_error("Unable to change device UUID. The device must be deactivated first.");
+		r = 0;
 		goto out;
+	}
 
 	/* Nothing to do if the name is in correct form already. */
 	if (!strcmp(name, new_name)) {
-		log_print("%s: name already in correct form", name);
+		log_print("%s: %s: name %salready in correct form", name,
+			  *uuid ? uuid : "[no UUID]", *uuid ? "and UUID " : "");
 		r = 1;
 		goto out;
 	}
@@ -3003,6 +3027,7 @@ static int _mangle(CMD_ARGS)
 
 out:
 	dm_free(new_name);
+	dm_free(new_uuid);
 	dm_task_destroy(dmt);
 	return r;
 }


