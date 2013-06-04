From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:19 +0000 (UTC)
Subject: dev-mornfall-activate - tests: add hide_dev/unhide_dev to aux
Message-ID: <20130604192819.BEC186125D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=249ea4c34c40ed98a649a439c65e4a17c951a2b8
Commit:        249ea4c34c40ed98a649a439c65e4a17c951a2b8
Parent:        1f73e992ef3e233608322cb804b283c3ecdaa72b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Apr 28 22:41:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 2 00:50:08 2013 +0200

tests: add hide_dev/unhide_dev to aux

Add helper func for easy filter adjustment.
---
 test/lib/aux.sh |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4339ef4..d09e1b7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -448,6 +448,22 @@ prepare_vg() {
 	vgcreate -c n $vg $devs
 }
 
+hide_dev() {
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	for dev in $@; do
+		filter=$(echo $filter | sed -e "s:\[:[ \"r|$dev|\", :")
+	done
+	lvmconf "$filter"
+}
+
+unhide_dev() {
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	for dev in $@; do
+		filter=$(echo $filter | sed -e "s:\"r|$dev|\", ::")
+	done
+	lvmconf "$filter"
+}
+
 lvmconf() {
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
 	if test "$DM_DEV_DIR" = "/dev"; then


