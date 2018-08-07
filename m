From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Aug 2018 12:07:06 -0400
Subject: 2018-06-01-stable - tests: check policy mq can be used with format2
Message-ID: <201808071607.w77G76JN028992@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=227a0d7336b2de30ccbc3875551e0dac6fa99068
Commit:        227a0d7336b2de30ccbc3875551e0dac6fa99068
Parent:        a41968c4b431a8d00f002fe6fb8cefc6a35050b8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 7 15:20:31 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 7 18:05:35 2018 +0200

tests: check policy mq can be used with format2

---
 test/shell/cache-metadata2.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
index 684ae67..92090b4 100644
--- a/test/shell/cache-metadata2.sh
+++ b/test/shell/cache-metadata2.sh
@@ -78,6 +78,12 @@ lvconvert --config 'allocation/cache_metadata_format=1' -y -H --cachepool $vg/cp
 check lv_field $vg/$lv1 cachemetadataformat "1"
 lvremove -f $vg
 
+lvcreate --type cache-pool --cachepolicy mq --cachemetadataformat 1 -L1 $vg/cpool
+check lv_field $vg/cpool cachemetadataformat "1"
+lvcreate -H -L10 -n $lv1 --cachemetadataformat 2 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemetadataformat "2"
+lvremove -f $vg
+
 fi
 #lvs -a -o name,cachemetadataformat,kernelmetadataformat,chunksize,cachepolicy,cachemode $vg
 


