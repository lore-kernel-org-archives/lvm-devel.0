From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Sep 2019 15:38:53 -0400
Subject: master - tests: metadata-zero-space more debugging
Message-ID: <201909121938.x8CJcrIo002804@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=196a9ed59fa65666a1efa26440166ace6206e545
Commit:        196a9ed59fa65666a1efa26440166ace6206e545
Parent:        39a0de68bdbd26bf64e2cc92731c9095c5d36e17
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 12 14:38:20 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 12 14:38:20 2019 -0500

tests: metadata-zero-space more debugging

---
 test/shell/metadata-zero-space.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index ec7b65c..1bd1eef 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -38,7 +38,7 @@ xxd meta.raw > meta.txt
 # to help debug if the next grep fails
 ls -l meta.txt
 head -n 100 meta.txt
-grep -A4 -B4 00001200 meta.txt
+grep -A4 -B4 1200 meta.txt
 
 grep -B1 "$vg {" meta.txt > meta.vg
 


