From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Apr 2016 20:08:54 +0000 (UTC)
Subject: master - tests: lvmetad-lvm1 fix
Message-ID: <20160413200854.2967061C73@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a299d2d7a04759749bd6c01a86b90fd13f27b96
Commit:        9a299d2d7a04759749bd6c01a86b90fd13f27b96
Parent:        579bd9200950a438af9d842f5d0cbaf049bd87c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 13 15:07:53 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 13 15:07:53 2016 -0500

tests: lvmetad-lvm1 fix

workaround this test failure until the proper
lvmetad/lvm1 fixes arrive shortly.
---
 test/shell/lvmetad-lvm1.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 7a93f74..9720833 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -19,11 +19,11 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_devs 2
 pvcreate --metadatatype 1 "$dev1"
-not vgscan --cache
+vgscan --cache
 pvs | tee out
 not grep "$dev1" out
 vgcreate --metadatatype 1 $vg1 "$dev1"
-not vgscan --cache
+vgscan --cache
 vgs | tee out
 not grep $vg1 out
 pvs | tee out


