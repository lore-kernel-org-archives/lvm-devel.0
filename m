From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 20:16:43 +0000 (UTC)
Subject: master - metadata: add comments describing lock_args for lvmlockd
Message-ID: <20150709201643.4829960072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb14bbdbc93a129f0ef9cf37314691b7fe79050e
Commit:        cb14bbdbc93a129f0ef9cf37314691b7fe79050e
Parent:        841c3478fd1a20560db4ef01bfe30a7f8beb6608
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 15:14:19 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 15:16:28 2015 -0500

metadata: add comments describing lock_args for lvmlockd

---
 lib/format_text/import_vsn1.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 3645fa2..a4dcdf1 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -600,6 +600,25 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 		return 0;
 	}
 
+	/*
+	 * The LV lock_args string is generated in lvmlockd, and the content
+	 * depends on the lock_type.
+	 *
+	 * lock_type dlm does not use LV lock_args, so the LV lock_args field
+	 * is just set to "dlm".
+	 *
+	 * lock_type sanlock uses the LV lock_args field to save the
+	 * location on disk of that LV's sanlock lock.  The disk name is
+	 * specified in the VG lock_args.  The lock_args string begins
+	 * with a version number, e.g. 1.0.0, followed by a colon, followed
+	 * by a number.  The number is the offset on disk where sanlock is
+	 * told to find the LV's lock.
+	 * e.g. lock_args = 1.0.0:70254592
+	 * means that the lock is located at offset 70254592.
+	 *
+	 * The lvmlockd code for each specific lock manager also validates
+	 * the lock_args before using it to access the lock manager.
+	 */
 	if (dm_config_get_str(lvn, "lock_args", &str)) {
 		if (!(lv->lock_args = dm_pool_strdup(mem, str)))
 			return_0;
@@ -828,6 +847,27 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 			goto bad;
 	}
 
+	/*
+	 * The VG lock_args string is generated in lvmlockd, and the content
+	 * depends on the lock_type.  lvmlockd begins the lock_args string
+	 * with a version number, e.g. 1.0.0, followed by a colon, followed
+	 * by a string that depends on the lock manager.  The string after
+	 * the colon is information needed to use the lock manager for the VG.
+	 *
+	 * For sanlock, the string is the name of the internal LV used to store
+	 * sanlock locks.  lvmlockd needs to know where the locks are located
+	 * so it can pass that location to sanlock which needs to access the locks.
+	 * e.g. lock_args = 1.0.0:lvmlock
+	 * means that the locks are located on the the LV "lvmlock".
+	 *
+	 * For dlm, the string is the dlm cluster name.  lvmlockd needs to use
+	 * a dlm lockspace in this cluster to use the VG.
+	 * e.g. lock_args = 1.0.0:foo
+	 * means that the host needs to be a member of the cluster "foo".
+	 *
+	 * The lvmlockd code for each specific lock manager also validates
+	 * the lock_args before using it to access the lock manager.
+	 */
 	if (dm_config_get_str(vgn, "lock_args", &str)) {
 		if (!(vg->lock_args = dm_pool_strdup(vg->vgmem, str)))
 			goto bad;


