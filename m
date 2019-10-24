From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Oct 2019 14:27:18 -0400
Subject: master - tests: lvmlockd-lv-types handle new cpool renaming
Message-ID: <201910241827.x9OIRIIT012489@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=221edf40305de4cab7441d88adf6a15b73c556c3
Commit:        221edf40305de4cab7441d88adf6a15b73c556c3
Parent:        0ba260e397ba7159eaccee8c0adab8fdb0664be7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 13:26:33 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 13:26:33 2019 -0500

tests: lvmlockd-lv-types handle new cpool renaming

---
 test/shell/lvmlockd-lv-types.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvmlockd-lv-types.sh b/test/shell/lvmlockd-lv-types.sh
index 44ff532..3503f24 100644
--- a/test/shell/lvmlockd-lv-types.sh
+++ b/test/shell/lvmlockd-lv-types.sh
@@ -131,9 +131,9 @@ check lva_field $vg/lv1 lockargs $LOCKARGS1
 
 lvconvert -y --type cache --cachepool $vg/cache1 $vg/lv1
 check lva_field $vg/lv1 lockargs $LOCKARGS1
-check lva_field $vg/cache1 lockargs ""
-check lva_field $vg/cache1_cdata lockargs ""
-check lva_field $vg/cache1_cmeta lockargs ""
+check lva_field $vg/cache1_cpool lockargs ""
+check lva_field $vg/cache1_cpool_cdata lockargs ""
+check lva_field $vg/cache1_cpool_cmeta lockargs ""
 
 lvconvert --splitcache $vg/lv1
 check lva_field $vg/lv1 lockargs $LOCKARGS1


