From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 11 Oct 2017 08:29:44 -0400
Subject: master - activation: fix locking resource name for activation lock
Message-ID: <201710111229.v9BCTiNA018910@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9bd7615fef1e4526bcc2c9fea67d2d038db6d917
Commit:        9bd7615fef1e4526bcc2c9fea67d2d038db6d917
Parent:        e61313843f835284303141bd514fcbcb08fb2463
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 9 15:36:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 11 14:24:28 2017 +0200

activation: fix locking resource name for activation lock

Avoid cutting away 1st. character for activation lock.
Unlike with VG name locks like #orphan we should not cut-off 1st.
characted from resource name.
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9140858..5345f7c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Avoid cutting 1st. character of resource name for activation lock.
   Support for encrypted devices in fsadm.
   Improve thin pool overprovisioning and repair warning messages.
 
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 230303b..245892e 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -51,8 +51,8 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_ACTIVATION:
 		if (dm_snprintf(lockfile, sizeof(lockfile),
-				"%s/A_%s", _lock_dir, resource + 1) < 0) {
-			log_error("Too long locking filename %s/A_%s.", _lock_dir, resource + 1);
+				"%s/A_%s", _lock_dir, resource) < 0) {
+			log_error("Too long locking filename %s/A_%s.", _lock_dir, resource);
 			return 0;
 		}
 


