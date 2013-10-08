From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Oct 2013 11:42:39 +0000 (UTC)
Subject: master - tests: lvconvert more thin extorg conversions
Message-ID: <20131008114239.AC93060F40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=273373bf53b34817481ef2c395c84a7cdf4f1998
Commit:        273373bf53b34817481ef2c395c84a7cdf4f1998
Parent:        7edf61186b6afdcc7ab8b44072818995cef3702b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 8 13:30:21 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 8 13:42:10 2013 +0200

tests: lvconvert more thin extorg conversions

Add test for conversion of pool and thin lv at the same time.
---
 test/shell/lvconvert-thin-external.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index a700b37..d9d4d19 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -144,5 +144,13 @@ lvs -a -o+origin_size,seg_size,segtype $vg
 lvremove -f $vg/extorg2
 # Only pool is left
 check vg_field $vg lv_count 1
+lvremove -ff $vg
+
+# Test conversion to the pool and thin external at the same time (rhbz #1003461)
+lvcreate -l50 -n pool $vg
+lvcreate -l100 -n thin $vg
+lvconvert --thin --thinpool $vg/pool $vg/thin --originname thin-origin
+check lv_field $vg/thin segtype thin
+check lv_field $vg/thin-origin segtype linear
 
 vgremove -ff $vg


