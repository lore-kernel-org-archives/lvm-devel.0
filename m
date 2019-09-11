From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Sep 2019 15:21:23 -0400
Subject: master - tests: metadata-zero-space add info for debugging
Message-ID: <201909111921.x8BJLNRS022804@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=772dbb1e39d007c770dd7ddb5ca912009658f8a0
Commit:        772dbb1e39d007c770dd7ddb5ca912009658f8a0
Parent:        447ba5f1c20161d2ca89e0673fc4b219f65209a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 14:20:59 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 11 14:20:59 2019 -0500

tests: metadata-zero-space add info for debugging

---
 test/shell/metadata-zero-space.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index 11c358b..f69aee5 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -35,6 +35,9 @@ dd if="$dev1" of=meta.raw bs=1M count=1
 
 xxd meta.raw > meta.txt
 
+# to help debug if the next grep fails
+grep -A4 -B4 00001200 meta.txt
+
 grep -B1 "$vg {" meta.txt > meta.vg
 
 cat meta.vg


