From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 16 Dec 2014 17:44:58 +0000 (UTC)
Subject: master - tests: skip cache tests in cluster
Message-ID: <20141216174458.7D0A060F6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e20bf7e71ace22f554a8c2f7abb7af14d1c90ac
Commit:        3e20bf7e71ace22f554a8c2f7abb7af14d1c90ac
Parent:        40e1d5b269fa76b839e3e8e2e7c9beb2bbbfed5e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 16 11:43:48 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 16 11:43:48 2014 -0600

tests: skip cache tests in cluster

The previous commit disabled cache types with cluster.
Disable the tests also.
---
 test/shell/lvchange-cache.sh       |    2 ++
 test/shell/lvconvert-cache-raid.sh |    2 ++
 test/shell/lvconvert-cache-thin.sh |    2 ++
 test/shell/lvconvert-cache.sh      |    2 ++
 test/shell/lvcreate-cache.sh       |    2 ++
 5 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 87a217a..3b108c1 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+test -e LOCAL_CLVMD && skip
+
 aux have_cache 1 3 0 || skip
 aux prepare_vg 3
 
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index faab251..f0e0d19 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_CLVMD && skip
+
 aux have_cache 1 3 0 || skip
 aux have_raid 1 0 0 || skip
 
diff --git a/test/shell/lvconvert-cache-thin.sh b/test/shell/lvconvert-cache-thin.sh
index 87256a4..09971b5 100644
--- a/test/shell/lvconvert-cache-thin.sh
+++ b/test/shell/lvconvert-cache-thin.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_CLVMD && skip
+
 aux have_cache 1 3 0 || skip
 aux have_thin 1 0 0 || skip
 
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index ed414ed..35b4ba8 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -13,6 +13,8 @@
 
 . lib/inittest
 
+test -e LOCAL_CLVMD && skip
+
 aux have_cache 1 3 0 || skip
 
 aux prepare_vg 5 80
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index f709d8b..6e9b33a 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -16,6 +16,8 @@
 
 . lib/inittest
 
+test -e LOCAL_CLVMD && skip
+
 aux have_cache 1 3 0 || skip
 
 # FIXME: parallel cache metadata allocator is crashing when used value 8000!


