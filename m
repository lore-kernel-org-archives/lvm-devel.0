From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 06:13:56 -0400
Subject: master - tests: check LV in proper VG
Message-ID: <201706301013.v5UADu5d020366@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=596cf2c6fabefb67c4d42d8aad055272b7c452b6
Commit:        596cf2c6fabefb67c4d42d8aad055272b7c452b6
Parent:        e84a145cf4f593a4560f109b486a1fa1d999fe2d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 11:30:57 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 12:09:10 2017 +0200

tests: check LV in proper VG

---
 test/shell/lvmetad-pvscan-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 8b1e8c2..c0b7f43 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -32,7 +32,7 @@ fail lvs $vg1
 fail lvchange -ay $vg1/$lv1
 vgimport $vg1
 check lv_exists $vg1
-check lv_field $vg/$lv1 lv_active ""
+check lv_field $vg1/$lv1 lv_active ""
 
 # Check that an LV cannot be activated by pvscan while VG is exported
 vgexport $vg1


