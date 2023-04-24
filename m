From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:39 +0000 (GMT)
Subject: main - tests: fix pattern for raid4
Message-ID: <20230424221439.A01823858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a003ba671bd4f38d9108f5dd174eccda1522c3b
Commit:        4a003ba671bd4f38d9108f5dd174eccda1522c3b
Parent:        7c8901dabde8d962a95a827f249ad50a86b0a42c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 22:41:54 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

tests: fix pattern for raid4

Since the strip in raid4 might be XOR - we might eventually end
with 2 blocks of 'B' on 2 disks - so will rest of stripe with 'b'.
---
 test/shell/integrity-caching.sh    | 2 +-
 test/shell/integrity-syncaction.sh | 2 +-
 test/shell/integrity.sh            | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/integrity-caching.sh b/test/shell/integrity-caching.sh
index 73d33de18..838bbded0 100644
--- a/test/shell/integrity-caching.sh
+++ b/test/shell/integrity-caching.sh
@@ -28,7 +28,7 @@ aux prepare_devs 6 80
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" ; while (z++ < 16384) printf "b" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
diff --git a/test/shell/integrity-syncaction.sh b/test/shell/integrity-syncaction.sh
index ededda010..0f8ce17d2 100644
--- a/test/shell/integrity-syncaction.sh
+++ b/test/shell/integrity-syncaction.sh
@@ -27,7 +27,7 @@ aux prepare_devs 3 40
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" ; while (z++ < 16384) printf "b" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 _prepare_vg() {
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index b55855ab4..1ba75d230 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -28,7 +28,7 @@ aux prepare_devs 5 64
 # Use awk instead of anoyingly long log out from printf
 #printf "%0.sA" {1..16384} >> fileA
 awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
-awk 'BEGIN { while (z++ < 4096) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 4096) printf "B" ; while (z++ < 16384) printf "b" }' > fileB
 awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data

