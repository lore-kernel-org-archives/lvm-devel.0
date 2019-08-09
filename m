From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:56 -0400
Subject: master - tests: accept also value 512
Message-ID: <201908091058.x79Awuuw031639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=505c1d56e8d48a479ef95c7890d3c9e066b66f33
Commit:        505c1d56e8d48a479ef95c7890d3c9e066b66f33
Parent:        1e553159d5147c601ae4b524198461309016b496
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 14:20:35 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:21 2019 +0200

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


