From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 16:33:31 -0400
Subject: master - tests: add debug to pvscan-cache deactivation
Message-ID: <201905232033.x4NKXV46030520@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eebb5e9fffd4602b0455ed9729b4b3d4d341bc1c
Commit:        eebb5e9fffd4602b0455ed9729b4b3d4d341bc1c
Parent:        e055b89d2896ebe8b8067ab21f38d7ddbe2df9df
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 23 15:32:46 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 15:32:46 2019 -0500

tests: add debug to pvscan-cache deactivation

---
 test/shell/pvscan-cache.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvscan-cache.sh b/test/shell/pvscan-cache.sh
index 20d3235..c351885 100644
--- a/test/shell/pvscan-cache.sh
+++ b/test/shell/pvscan-cache.sh
@@ -59,7 +59,8 @@ check lv_field $vg1/$lv1 lv_active ""
 pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
-lvchange -an $vg1/$lv1
+lvchange -an -vvvv $vg1/$lv1
+dmsetup ls
 lvremove $vg1/$lv1
 
 # When MDA is ignored on PV, do not read any VG


