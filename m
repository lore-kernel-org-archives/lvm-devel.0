From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Sep 2019 12:20:26 -0400
Subject: master - tests: more debug in metadata-zero-space
Message-ID: <201909121620.x8CGKQ3f023579@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82b887a4cfa12f32781cc0dc89c51d89658179a1
Commit:        82b887a4cfa12f32781cc0dc89c51d89658179a1
Parent:        1fe04f89efa97bf25b7b5ca6f382e957a9adf43d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 11:19:44 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 11:19:44 2019 -0500

tests: more debug in metadata-zero-space

---
 test/shell/metadata-zero-space.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index f69aee5..ec7b65c 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -36,6 +36,8 @@ dd if="$dev1" of=meta.raw bs=1M count=1
 xxd meta.raw > meta.txt
 
 # to help debug if the next grep fails
+ls -l meta.txt
+head -n 100 meta.txt
 grep -A4 -B4 00001200 meta.txt
 
 grep -B1 "$vg {" meta.txt > meta.vg


