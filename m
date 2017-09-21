From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 21 Sep 2017 11:17:34 -0400
Subject: master - blkdeactivate: also try to unmount /boot on blkdeactivate -u if on top of supported device
Message-ID: <201709211517.v8LFHYLs021473@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=096fcb5a6e373763bcdf1d182456f206c06cec43
Commit:        096fcb5a6e373763bcdf1d182456f206c06cec43
Parent:        584b4ae38bca05c0bbc6a097b549372c39727f3b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 21 15:23:24 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 21 17:15:48 2017 +0200

blkdeactivate: also try to unmount /boot on blkdeactivate -u if on top of supported device

There's nothing special about /boot other than it's used during boot.
But when blkdeactivate is called either on all devices or including a
device where the /boot is on top, we should also include this mount
point when doing unmount before deactivation of supported devices.
---
 WHATS_NEW_DM                |    1 +
 scripts/blkdeactivate.sh.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index df72a25..5a11e2e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Also try to unmount /boot on blkdeactivate -u if on top of supported device.
   Use blkdeactivate -r wait in blk-availability systemd service/initscript.
   Add blkdeactivate -r wait option to wait for MD resync/recovery/reshape.
   Fix blkdeactivate regression with failing DM/MD devs deactivation (1.02.142).
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 71cc241..11b5983 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -97,7 +97,7 @@ declare -A SKIP_VG_LIST=()
 # listed here will be added to SKIP_DEVICE_LIST (and SKIP_VG_LIST) automatically.
 # (list is an associative array!)
 #
-declare -A SKIP_UMOUNT_LIST=(["/"]=1 ["/boot"]=1 \
+declare -A SKIP_UMOUNT_LIST=(["/"]=1 \
                              ["/lib"]=1 ["/lib64"]=1 \
                              ["/bin"]=1 ["/sbin"]=1 \
                              ["/var"]=1 ["/var/log"]=1 \


