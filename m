From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:44:39 -0400
Subject: stable-2.02 - tests: accept also value 512
Message-ID: <201906251544.x5PFid8L012195@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=788d89c4127f69c813813e6a192fe44d8c1abc7a
Commit:        788d89c4127f69c813813e6a192fe44d8c1abc7a
Parent:        e0a176f49ab09d2afaea73cafa4d7b41ade0c345
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 14:20:35 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 14:20:35 2019 +0200

tests: accept also value 512

Older kernels provide fixed value 512 instead of 0.
---
 test/shell/lvchange-cache.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index ab7c8b0..93c8c3b 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -88,7 +88,8 @@ grep 'random_threshold=4' out
 else
 # When MQ is emulated by SMQ policy it does not hold settings.
 # So just skip testing of param changes when sequential_threshold=0
-grep 'sequential_threshold=0' out
+# or some older kernel instancies show also value 512
+grep 'sequential_threshold=0' out || grep 'sequential_threshold=512' out
 fi
 
 fi  # have_cache 1 5 0


