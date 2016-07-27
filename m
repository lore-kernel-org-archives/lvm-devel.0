From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 Jul 2016 14:21:40 +0000 (UTC)
Subject: master - tests: check we don't warn when converting to thin LV
Message-ID: <20160727142140.6988560268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ad30b0b38a212a51af5c25b0783cb595fa3ab76
Commit:        9ad30b0b38a212a51af5c25b0783cb595fa3ab76
Parent:        0c3a09f1d7423c077ae513baecd2260928500ade
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 27 15:59:48 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 27 16:20:57 2016 +0200

tests: check we don't warn when converting to thin LV

Tool produced warning for non-zeroing thin-pools.
---
 test/shell/lvconvert-thin-external.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 712e368..470e87c 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -167,5 +167,13 @@ lvcreate -l100 -n thin $vg
 lvconvert --yes --thin --thinpool $vg/pool $vg/thin --originname thin-origin
 check lv_field $vg/thin segtype thin
 check lv_field $vg/thin-origin segtype linear
+lvremove -ff $vg
+
+# Test conversion with non-zeroing thin-pool, should not WARN about zeroing
+lvcreate -l50 -n pool $vg
+lvcreate -l100 -n thin $vg
+lvconvert --yes --thin --thinpool $vg/pool $vg/thin --zero n --originname thin-origin 2>&1 | tee out
+not grep "not zeroed" out
+check lv_field $vg/pool zero ""
 
 vgremove -ff $vg


