From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 10:26:11 +0000 (UTC)
Subject: master - tests: more permissive on test percent value
Message-ID: <20160913102611.B6CB360D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08c94de79895ac94ebc346fc440dbb23eaa98b45
Commit:        08c94de79895ac94ebc346fc440dbb23eaa98b45
Parent:        d34e315b8dbe3bd469499e62feb02b27aaf7b179
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 11:30:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 12:25:36 2016 +0200

tests: more permissive on test percent value

Just check there is some output.
Values may slightly differ per policy target version.
---
 test/shell/lvcreate-cache.sh |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index c53d243..bed3ec2 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -86,11 +86,12 @@ lvcreate --type cache-pool  -L1 $vg/cpool
 lvcreate -H -L4 -n $lv1 $vg/cpool
 
 check lv_field $vg/$lv1 copy_percent "0.00"
-check lv_field $vg/$lv1 data_percent "0.00"
-check lv_field $vg/$lv1 metadata_percent "0.78"
+# there should be something present (value differs per policy version)
+test -n "$(get lv_field $vg/$lv1 data_percent)"
+test -n "$(get lv_field $vg/$lv1 metadata_percent)"
 check lv_field $vg/cpool copy_percent "0.00"
-check lv_field $vg/cpool data_percent "0.00"
-check lv_field $vg/cpool metadata_percent "0.78"
+test -n "$(get lv_field $vg/cpool data_percent)"
+test -n "$(get lv_field $vg/cpool metadata_percent)"
 # check we also display percent value for segmented output (-o+devices)
 lvs -a -o+devices $vg/cpool | tee out
 grep "0.00" out


