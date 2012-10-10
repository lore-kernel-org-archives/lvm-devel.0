From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:24 +0000 (UTC)
Subject: master - libdm: add mangling support for dm_task_set_newuuid
Message-ID: <20121010151824.F416B2EA7@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e71ecbaf6137fa6b6e3ca5c25c090369fe69dd4
Commit:        7e71ecbaf6137fa6b6e3ca5c25c090369fe69dd4
Parent:        a621795a3c011d3e3cf9031f09f2bdfa05d4dc8c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:01:13 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:16:14 2012 +0200

libdm: add mangling support for dm_task_set_newuuid

---
 libdm/ioctl/libdm-iface.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 0dd25ef..04e458c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -736,11 +736,32 @@ int dm_task_set_add_node(struct dm_task *dmt, dm_add_node_t add_node)
 
 int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 {
+	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
+	char mangled_uuid[DM_UUID_LEN];
+	int r = 0;
+
 	if (strlen(newuuid) >= DM_UUID_LEN) {
 		log_error("Uuid \"%s\" too long", newuuid);
 		return 0;
 	}
 
+	if (!check_multiple_mangled_string_allowed(newuuid, "new UUID", mangling_mode))
+		return_0;
+
+	if (mangling_mode != DM_STRING_MANGLING_NONE &&
+	    (r = mangle_string(newuuid, "new UUID", strlen(newuuid), mangled_uuid,
+			       sizeof(mangled_uuid), mangling_mode)) < 0) {
+		log_error("Failed to mangle new device UUID \"%s\"", newuuid);
+		return 0;
+	}
+
+	if (r) {
+		log_debug("New device uuid mangled [%s]: %s --> %s",
+			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+			  newuuid, mangled_uuid);
+		newuuid = mangled_uuid;
+	}
+
 	if (!(dmt->newname = dm_strdup(newuuid))) {
 		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
 		return 0;


