From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 11:09:17 -0500
Subject: master - tests: add lvchange cachemode passthrough in cache-single-options
Message-ID: <201811081609.wA8G9Hfp027229@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=025332edc2c608e5892af373ebb764ac8ec5d8be
Commit:        025332edc2c608e5892af373ebb764ac8ec5d8be
Parent:        8794fb71dbc3db8bebf133e6048bcd6ffdad7568
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 8 10:08:38 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 10:08:38 2018 -0600

tests: add lvchange cachemode passthrough in cache-single-options

---
 test/shell/cache-single-options.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 62cfeaf..d9e7e01 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -236,6 +236,10 @@ lvchange --cachemode writethrough $vg/$lv1
 
 check lv_field $vg/$lv1 cachemode "writethrough"
 
+lvchange --cachemode passthrough $vg/$lv1
+
+check lv_field $vg/$lv1 cachemode "passthrough"
+
 lvchange -an $vg/$lv1
 
 lvchange --cachepolicy mq --cachesettings 'migration_threshold=100' $vg/$lv1


