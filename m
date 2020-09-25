From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:12 +0000 (GMT)
Subject: master - tests: add small delay
Message-ID: <20200925210712.E60D33971C47@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbc164991afc5d28bcf12bd4709c4137c913e412
Commit:        bbc164991afc5d28bcf12bd4709c4137c913e412
Parent:        a89ac3bf6f84be5a021691d02bad3ac5e315da78
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 22:09:37 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:59:35 2020 +0200

tests: add small delay

Prevent there is no i.e. udev trying to open our device.
---
 test/shell/snapshot-remove-dmsetup.sh | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 19411ce93..2ef65a596 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -59,7 +59,9 @@ dmsetup resume $vg1-snap
 wait $DMPID
 
 
-# Try how force removal works
+# Try how force removal works (and wait till there is no user)
+sync
+sleep .5
 dmsetup suspend $vg-$lv1
 # needs to fail as device is still open
 not dmsetup remove --force $vg1-snap &


