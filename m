From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:22 +0000 (UTC)
Subject: master - tests: allow to use sysfs filter
Message-ID: <20150422092022.0F9FA60213@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30e8b284a7d24fa996d9eeb5b71510d49c9840fb
Commit:        30e8b284a7d24fa996d9eeb5b71510d49c9840fb
Parent:        16ee4642c732bbe80009d4b1471c8a84f4279099
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 21 13:27:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 09:09:26 2015 +0200

tests: allow to use sysfs filter

Current filtering logic in lvm2 needs some rework.
For now at least enable it in test suite.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d0d2aa8..55dd60b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -672,7 +672,7 @@ devices/scan = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
 devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
 devices/cache_dir = "$TESTDIR/etc"
-devices/sysfs_scan = 0
+devices/sysfs_scan = 1
 devices/default_data_alignment = 1
 devices/md_component_detection  = 0
 log/syslog = 0


