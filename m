From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Sep 2015 15:23:23 +0000 (UTC)
Subject: master - lockd: vgrename fixes
Message-ID: <20150903152323.9046E60F0F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96dc03b33782cf0e33f5fdf57cd8eb475e4bd7c9
Commit:        96dc03b33782cf0e33f5fdf57cd8eb475e4bd7c9
Parent:        d1d00fdeec04b1c856dfbe2d1ad8914e0968acfb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 3 10:21:44 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 3 10:21:44 2015 -0500

lockd: vgrename fixes

If busy locks in lvmlockd prevent vgrename, use the
correct error exit path, and print a user-friendly
error message.
---
 lib/locking/lvmlockd.c |    6 ++++++
 tools/vgrename.c       |    2 +-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f3e2e2c..983ecc9 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2423,6 +2423,12 @@ int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	daemon_reply_destroy(reply);
+
+	/* Other hosts have not stopped the lockspace. */
+	if (result == -EBUSY) {
+		log_error("Lockspace for \"%s\" not stopped on other hosts", vg->name);
+		return 0;
+	}
 	
 	if (!ret) {
 		log_error("lockd_rename_vg_before lvmlockd result %d", result);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 7e77b57..620345b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -150,7 +150,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		stack;
 
 	if (!lockd_rename_vg_before(cmd, vg))
-		return_0;
+		goto error;
 
 	/* Change the volume group name */
 	vg_rename(cmd, vg, vg_name_new);


