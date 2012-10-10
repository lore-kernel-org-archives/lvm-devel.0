From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:37:05 +0000 (UTC)
Subject: master - WHATS_NEW: update
Message-ID: <20121010153706.1EC36A2BEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3af43af493dabf0dda0527f96c617b0947deb83c
Commit:        3af43af493dabf0dda0527f96c617b0947deb83c
Parent:        a5306421ddd014598a2d94248ff9eb75df2ea2b0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 17:36:37 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 17:36:37 2012 +0200

WHATS_NEW: update

---
 WHATS_NEW_DM |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 338cfaf..22d4b01 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,10 @@
 Version 1.02.77 -
 =================================
+  Update man page to reflect that dm UUIDs are being mangled as well.
+  Apply 'dmsetup mangle' for dm UUIDs besides dm names.
+  Add 'mangled_uuid' and 'unmangled_uuid' fields to dmsetup info -c -o.
+  Mangle device UUID on dm_task_set_uuid/newuuid call if necessary.
+  Add dm_task_get_uuid_mangled/unmangled to libdevmapper.
   Always reset delay_resume_if_new flag when stacking thin pool.
   Don't create value for dm_config_node and require dm_config_create_value call.
   Check for existing new_name for dmsetup rename.


