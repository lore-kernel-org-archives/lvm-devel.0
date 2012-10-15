From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Oct 2012 13:41:16 +0000 (UTC)
Subject: master - libdm: fix comments in libdevmapper.h
Message-ID: <20121015134117.0C3FE22E1@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ff080c59190caa6f5002d73f4da63b7e4e39620
Commit:        3ff080c59190caa6f5002d73f4da63b7e4e39620
Parent:        8290de964fbf0e6dcb9622f2e234a1bd794ea2e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 15 15:40:37 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 15 15:40:37 2012 +0200

libdm: fix comments in libdevmapper.h

---
 libdm/libdevmapper.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 70862f3..c853ab4 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -168,10 +168,10 @@ int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
 /*
  * This function returns dm device's UUID based on the value
  * of the mangling mode set during preceding dm_task_run call:
- *   - unmangled name for DM_STRING_MANGLING_{AUTO, HEX},
- *   - name without any changes for DM_STRING_MANGLING_NONE.
+ *   - unmangled UUID for DM_STRING_MANGLING_{AUTO, HEX},
+ *   - UUID without any changes for DM_STRING_MANGLING_NONE.
  *
- * To get mangled or unmangled form of the name directly, use
+ * To get mangled or unmangled form of the UUID directly, use
  * dm_task_get_uuid_mangled or dm_task_get_uuid_unmangled function.
  */
 const char *dm_task_get_uuid(const struct dm_task *dmt);


