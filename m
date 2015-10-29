From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:54 +0000 (UTC)
Subject: master - tests: fix wrong line has been commented
Message-ID: <20151029113954.354A560E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3720eb63bed5d087a13d184894197373ebbbaeba
Commit:        3720eb63bed5d087a13d184894197373ebbbaeba
Parent:        8b5525383f2070a6df8508bfe5696324ca6acb54
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:30:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:39:07 2015 +0100

tests: fix wrong line has been commented

---
 test/shell/snapshot-remove-dmsetup.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 395fad1..6a4f9d2 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -36,12 +36,12 @@ mount -o errors=remount-ro "$DM_DEV_DIR/$vg1/snap" mnt
 
 sync
 
-# intetionally suspend layer bellow
+# intentionally suspend layer bellow
 dmsetup suspend $vg-$lv1
 
 # now this should pass without blocking
-#dmsetup suspend --noflush --nolockfs $vg1-snap &
-dmsetup suspend $vg1-snap &
+dmsetup suspend --noflush --nolockfs $vg1-snap &
+#dmsetup suspend $vg1-snap &
 
 sleep .5
 


