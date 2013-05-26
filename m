From: Petr Rockai <mornfall@fedoraproject.org>
Date: Sun, 26 May 2013 17:11:54 +0000 (UTC)
Subject: dev-mornfall-nix - test: Add hide_dev/unhide_dev to aux for easy filter adjustment.
Message-ID: <20130526171154.BDF1960F9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7351419f496f46e214f6139cdfe04565fbde51db
Commit:        7351419f496f46e214f6139cdfe04565fbde51db
Parent:        a50d2baf0bb2cda25002d9d627ede030296b83ef
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Apr 28 22:41:15 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun May 26 18:54:46 2013 +0200

test: Add hide_dev/unhide_dev to aux for easy filter adjustment.

---
 test/lib/aux.sh |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4339ef4..00e0da4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -448,6 +448,22 @@ prepare_vg() {
 	vgcreate -c n $vg $devs
 }
 
+hide_dev() {
+    filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+    for dev in $@; do
+	filter=$(echo $filter | sed -e "s:\[:[ \"r|$dev|\", :")
+    done
+    lvmconf "$filter"
+}
+
+unhide_dev() {
+    filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+    for dev in $@; do
+	filter=$(echo $filter | sed -e "s:\"r|$dev|\", ::")
+    done
+    lvmconf "$filter"
+}
+
 lvmconf() {
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
 	if test "$DM_DEV_DIR" = "/dev"; then


