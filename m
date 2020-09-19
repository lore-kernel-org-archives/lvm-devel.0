From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:39:00 +0000 (GMT)
Subject: master - tests: skip with fail of first prepare_scsi
Message-ID: <20200919223900.294973857C6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1074da20d309cf07be472c82a060e088f78127e
Commit:        a1074da20d309cf07be472c82a060e088f78127e
Parent:        e556c7b7c641c78f7bdd94120d6e79860a6220aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:03:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 23:03:06 2020 +0200

tests: skip with fail of first prepare_scsi

---
 test/shell/writecache-blocksize.sh | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 964ee205c..3685fdd05 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -137,7 +137,7 @@ _run_test() {
 }
 
 # scsi_debug devices with 512 LBS 512 PBS
-aux prepare_scsi_debug_dev 256
+aux prepare_scsi_debug_dev 256 || skip
 aux prepare_devs 2 64
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
@@ -160,7 +160,7 @@ aux cleanup_scsi_debug_dev
 
 
 # lbs=512, pbs=4096
-aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3 || skip
+aux prepare_scsi_debug_dev 256 sector_size=512 physblk_exp=3
 aux prepare_devs 2 64
 
 _check_env "512" "4096"


