From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:23:15 +0000 (UTC)
Subject: master - tests: missed exclusive activation
Message-ID: <20140325232315.D6A7061487@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2614c686670559b75b01ad9893fbd9338690d9f
Commit:        a2614c686670559b75b01ad9893fbd9338690d9f
Parent:        5b900dbef53d18dcc9bfcf939ffe991e5ec9fbb1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 26 00:22:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:22:23 2014 +0100

tests: missed exclusive activation

---
 test/shell/covercmd.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 54fe192..06a9082 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -27,7 +27,7 @@ pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 "$dev5"
 vgcreate $vg $(cat DEVICES)
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 
-lvcreate -l 5 -n $lv1 $vg
+lvcreate -aey -l 5 -n $lv1 $vg
 lvcreate -s -l 5 -n $lv2 $vg/$lv1
 
 if aux have_readline; then


