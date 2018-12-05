From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Dec 2018 13:15:00 -0500
Subject: master - tests: lvm-on-md udev issues
Message-ID: <201812051815.wB5IF0KO011683@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73687b7b75c4f12b6f21ba829898b4d13422db1c
Commit:        73687b7b75c4f12b6f21ba829898b4d13422db1c
Parent:        752b1e95f4f12225e6ed9302f078b3545e758549
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 5 12:14:17 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 5 12:14:17 2018 -0600

tests: lvm-on-md udev issues

---
 test/shell/lvm-on-md.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index a3e83d9..4f4a0c4 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -85,5 +85,8 @@ cat out
 not grep "prefers device" out
 
 vgchange -an $vg
+aux udev_wait
+
+aux cleanup_md_dev
 
-vgremove -f $vg
+# vgremove -f $vg


