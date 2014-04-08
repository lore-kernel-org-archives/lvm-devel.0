From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:03:08 +0000 (UTC)
Subject: master - tests: check prohibited names
Message-ID: <20140408090308.5E03360D55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87e559f1eca6e3d2cc64d2b6401067ef2efa93ed
Commit:        87e559f1eca6e3d2cc64d2b6401067ef2efa93ed
Parent:        bfbf6b7c122bc1851834daeec8ade6e1becaf454
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 20:27:34 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:16 2014 +0200

tests: check prohibited names

---
 test/shell/lvcreate-usage.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 105fbce..2a0e0a6 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -150,3 +150,11 @@ lvcreate -L 32m -n $lv -i2 --stripesize 128k --readahead auto $vg
 check lv_field $vg/$lv lv_read_ahead "auto"
 check lv_field $vg/$lv lv_kernel_read_ahead "512.00k"
 lvremove -ff $vg
+
+# prohibited names
+for i in pvmove snapshot ; do
+	invalid lvcreate -l1 -n ${i}1 $vg
+done
+for i in _cdata _cmeta _mimage _mlog _pmspare _tdata _tmeta _vorigin ; do
+	invalid lvcreate -l1 -n s_${i}_1 $vg
+done


