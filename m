From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 15:34:10 +0000 (UTC)
Subject: master - tests: put vars in quotes
Message-ID: <20140317153410.CFEE760E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e3d208f7c2aa3964ae76a7fc108bf63957ef4bd6
Commit:        e3d208f7c2aa3964ae76a7fc108bf63957ef4bd6
Parent:        c1ce2cc86cb1a9bba16b62119829e1e1ddc0ff87
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 16:30:52 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 16:30:52 2014 +0100

tests: put vars in quotes

This shell var has space in middle
---
 test/shell/snapshot-usage.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index a50eeb2..095fddb 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -80,12 +80,12 @@ vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
 lvcreate -V50 -L10 -n $lv1 -s $vg1
 CHECK_ACTIVE="active"
 test ! -e LOCAL_CLVMD || CHECK_ACTIVE="local exclusive"
-check lv_field $vg1/$lv1 lv_active ${CHECK_ACTIVE}
+check lv_field $vg1/$lv1 lv_active "$CHECK_ACTIVE"
 lvchange -an $vg1
 
 # On cluster snapshot gets exclusive activation
 lvchange -ay $vg1
-check lv_field $vg1/$lv1 lv_active ${CHECK_ACTIVE}
+check lv_field $vg1/$lv1 lv_active "$CHECK_ACTIVE"
 
 # Test removal of opened (bug unmounted) snapshot (device busy) for a while
 sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &


