From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:12 -0400
Subject: master - tests: again disable this raid test
Message-ID: <201805121626.w4CGQCpe007900@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38b4354494d3e6742d082c82ae7fc957be44e7e1
Commit:        38b4354494d3e6742d082c82ae7fc957be44e7e1
Parent:        ec0f5c2bf67df53072196f1630f3407501384397
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 12:02:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:05:50 2018 +0200

tests: again disable this raid test

Still kills testing machines even with 4.17-rc4 kernels
on reshaping.
---
 test/shell/lvconvert-raid-reshape.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 28bff0d..e621318 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -18,7 +18,7 @@ LVM_SKIP_LARGE_TESTS=0
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip # needed to address RHBZ#1501145
+aux have_raid 1 13 99 || skip # needed to address RHBZ#1501145
 
 # Temporarily skip reshape tests on single-core CPUs until there's a fix for
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20


