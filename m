From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 21 Sep 2017 11:17:32 -0400
Subject: master - blk-availability: use blkdeactivate -r wait in blk-availability systemd service/initscript
Message-ID: <201709211517.v8LFHW3T021451@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=584b4ae38bca05c0bbc6a097b549372c39727f3b
Commit:        584b4ae38bca05c0bbc6a097b549372c39727f3b
Parent:        95087c8f96c784cb91bda1433599abe75d917b80
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 21 15:10:23 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 21 17:10:15 2017 +0200

blk-availability: use blkdeactivate -r wait in blk-availability systemd service/initscript

---
 WHATS_NEW_DM                                       |    1 +
 scripts/blk_availability_init_red_hat.in           |    2 +-
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 783a542..df72a25 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Use blkdeactivate -r wait in blk-availability systemd service/initscript.
   Add blkdeactivate -r wait option to wait for MD resync/recovery/reshape.
   Fix blkdeactivate regression with failing DM/MD devs deactivation (1.02.142).
   Fix typo in blkdeactivate's '--{dm,lvm,mpath}options' option name.
diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 657616e..73d52ac 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -33,7 +33,7 @@
 
 sbindir=@sbindir@
 script=blkdeactivate
-options="-u -l wholevg -m disablequeueing"
+options="-u -l wholevg -m disablequeueing -r wait"
 
 LOCK_FILE="/var/lock/subsys/blk-availability"
 
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index cc4c678..10c3f44 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -7,7 +7,7 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 ExecStart=/usr/bin/true
-ExecStop=@sbindir@/blkdeactivate -u -l wholevg -m disablequeueing
+ExecStop=@sbindir@/blkdeactivate -u -l wholevg -m disablequeueing -r wait
 RemainAfterExit=yes
 
 [Install]


