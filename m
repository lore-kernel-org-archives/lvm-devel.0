From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Jun 2015 20:17:47 +0000 (UTC)
Subject: master - tests: tests needs pre 1.13 thin-pool extorg
Message-ID: <20150626201747.E2E40600C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02767c5eb1f9e4a15c5f5134903c292ea499213d
Commit:        02767c5eb1f9e4a15c5f5134903c292ea499213d
Parent:        03c4fee5a7afeeae0b3c215779d24b5faaa1ac26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 26 22:16:01 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 26 22:16:01 2015 +0200

tests: tests needs pre 1.13 thin-pool extorg

This test is testing older style, so disable feature when present.
---
 test/shell/lvcreate-thin-external.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 9e907a6..8507836 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -30,6 +30,10 @@ aux prepare_pvs 2 64
 
 vgcreate $vg -s 64K $(cat DEVICES)
 
+# Newer thin-pool target (>= 1.13) supports unaligned external origin
+# But this test is written to test and expect older behavior
+aux lvmconf 'global/thin_disabled_features = [ "external_origin_extend" ]'
+
 # Test validation for external origin being multiple of thin pool chunk size
 lvcreate -L10M -T $vg/pool192 -c 192k
 lvcreate -an -pr -Zn -l1 -n $lv1 $vg


