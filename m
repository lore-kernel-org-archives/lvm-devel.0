From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jun 2014 09:24:18 +0000 (UTC)
Subject: master - tests: add udev sync point
Message-ID: <20140620092418.580AC6019A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93597bcbdc791daf7308c839f245f6951900d7a7
Commit:        93597bcbdc791daf7308c839f245f6951900d7a7
Parent:        548269a1ddeb8fa2cfc6a9fd95c5fb2c398914a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 20 11:11:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 20 11:14:29 2014 +0200

tests: add udev sync point

Missed synchronization with udev may lead to error on vgcreate,
if previous vgremove was not handled fast enough by udev.
---
 test/shell/snapshot-usage.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index c0a14c6..dcf2886 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -213,6 +213,12 @@ vgremove -ff $vg1
 # Can't test >= 16T devices on 32bit
 test "$TSIZE" = 15P || exit 0
 
+# synchronize with udev activity
+# FIXME - otherwise sequence of vgremove followed by vgcreate may fail...
+# as there could be still remaing links in /dev
+# Unusure if 'vgcreate' should do this type of detection in udev mode.
+aux udev_wait
+
 # Check usability with largest extent size
 pvcreate "$DM_DEV_DIR/$vg/$lv"
 vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"


