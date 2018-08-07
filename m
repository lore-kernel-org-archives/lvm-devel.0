From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:01:29 -0400
Subject: master - tests: check policy mq can be used with format2
Message-ID: <201808071601.w77G1T0b027136@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54668feaabead997cdf099c970999af667bcf274
Commit:        54668feaabead997cdf099c970999af667bcf274
Parent:        d1310242550e28dfe7c386a78435235955963c95
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 15:20:31 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 17:59:50 2018 +0200

tests: check policy mq can be used with format2

---
 test/shell/cache-metadata2.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
index 57c6e23..0270f5d 100644
--- a/test/shell/cache-metadata2.sh
+++ b/test/shell/cache-metadata2.sh
@@ -88,6 +88,12 @@ lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
 check lv_field $vg/$lv1 cachemetadataformat "2"
 lvremove -f $vg
 
+lvcreate --type cache-pool --cachepolicy mq --cachemetadataformat 1 -L1 $vg/cpool
+check lv_field $vg/cpool cachemetadataformat "1"
+lvcreate -H -L10 -n $lv1 --cachemetadataformat 2 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemetadataformat "2"
+lvremove -f $vg
+
 fi
 #lvs -a -o name,cachemetadataformat,kernelmetadataformat,chunksize,cachepolicy,cachemode $vg
 


