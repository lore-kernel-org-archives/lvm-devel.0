From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:16 +0000 (GMT)
Subject: stable-2.02 - tests: add small delay
Message-ID: <20201016191216.1C0F8384640D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1d7d3db571e09a25aa7329056f5e052932519212
Commit:        1d7d3db571e09a25aa7329056f5e052932519212
Parent:        2de99760f7a3364a3a33373b6d28782c4423e4fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 23 22:09:37 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: add small delay

Prevent there is no i.e. udev trying to open our device.
---
 test/shell/snapshot-remove-dmsetup.sh | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index a7925d5d5..55957eb0c 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -61,7 +61,9 @@ dmsetup resume $vg1-snap
 wait $DMPID
 
 
-# Try how force removal works
+# Try how force removal works (and wait till there is no user)
+sync
+sleep .5
 dmsetup suspend $vg-$lv1
 # needs to fail as device is still open
 not dmsetup remove --force $vg1-snap &


