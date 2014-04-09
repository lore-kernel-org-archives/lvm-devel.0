From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Apr 2014 12:53:58 +0000 (UTC)
Subject: master - lvmetad: fix lost bootloader area information
Message-ID: <20140409125358.9FF6260EC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10e10cfa4fd802ffe404c0afb30ad896003c9437
Commit:        10e10cfa4fd802ffe404c0afb30ad896003c9437
Parent:        87e559f1eca6e3d2cc64d2b6401067ef2efa93ed
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 9 14:42:40 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 9 14:53:45 2014 +0200

lvmetad: fix lost bootloader area information

The refactoring made by 732859d21f3b41bdb188f92b60f25d5c94dcee8a
caused this. The former "ea" was not renamed to "ba" and we used
incorrect tree node name to search for the value.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1888cfd..ebb0f09 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix lost information about bootloader area when using lvmetad.
   Don't require --major to be specified when using -My option on kernels > 2.4.
   Add configure --disable-thin_check_needs_check to support old thin_check.
   Use thin_check --clear-needs-check-flag by default.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0dd2c81..c1eb4aa 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -349,7 +349,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 
 	i = 0;
 	do {
-		sprintf(da_id, "ea%d", i);
+		sprintf(da_id, "ba%d", i);
 		da = dm_config_find_node(cn->child, da_id);
 		if (da) {
 			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;


