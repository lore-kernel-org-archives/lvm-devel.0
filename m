From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Jun 2015 13:20:22 +0000 (UTC)
Subject: master - tests: workaround udev problem
Message-ID: <20150624132022.59F3A60045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44c7bc0262b6719efe75ecb6eb32eaab359e5779
Commit:        44c7bc0262b6719efe75ecb6eb32eaab359e5779
Parent:        e217873ed6ef7d77974fa10bfee4609160d7091d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 13:21:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:19:53 2015 +0200

tests: workaround udev problem

If udev has not removed 'dir' entry - just issue TEST WARNING, clear
dir, but do not fail whole rest of test.
---
 test/shell/profiles-thin.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 0c7fb61..5940cc6 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -59,6 +59,11 @@ check lv_field $vg/pool_performance zero ""
 
 vgremove -ff $vg
 
+if test -d "$DM_DEV_DIR/$vg" ; then
+	should not echo "Udev has left \"$DM_DEV_DIR/$vg\"!"
+	rm -rf "$DM_DEV_DIR/$vg"
+fi
+
 # The profile must be also applied if using the profile
 # for the whole VG - any LVs inherit this profile then.
 vgcreate --profile thin-performance $vg "$dev1"


