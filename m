From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:30 +0000 (UTC)
Subject: master - cleanup: simplify code
Message-ID: <20160421231830.4A24D61C15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d4f9defc31f0459f91979909a0c94bbb87af9c0
Commit:        9d4f9defc31f0459f91979909a0c94bbb87af9c0
Parent:        c9373a0c2ad42d51db6036fc506b9369264d29e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:19:53 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 00:22:02 2016 +0200

cleanup: simplify code

dm_strncpy() also check the size fits.
---
 lib/locking/file_locking.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index a8d041a..230303b 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -148,13 +148,11 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 
 	/* Get lockfile directory from config file */
 	locking_dir = find_config_tree_str(cmd, global_locking_dir_CFG, NULL);
-	if (strlen(locking_dir) >= sizeof(_lock_dir)) {
+	if (!dm_strncpy(_lock_dir, locking_dir, sizeof(_lock_dir))) {
 		log_error("Path for locking_dir %s is invalid.", locking_dir);
 		return 0;
 	}
 
-	strcpy(_lock_dir, locking_dir);
-
 	(void) dm_prepare_selinux_context(_lock_dir, S_IFDIR);
 	r = dm_create_dir(_lock_dir);
 	(void) dm_prepare_selinux_context(NULL, 0);


