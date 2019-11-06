From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 6 Nov 2019 10:21:26 -0500
Subject: master - test: Fix metadata-zero-space with long VG names
Message-ID: <201911061521.xA6FLQ6a005310@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8263e62b00959c2bef18dff7821b242aefd5547f
Commit:        8263e62b00959c2bef18dff7821b242aefd5547f
Parent:        c67a03727b427f7b6a1ae4375e0d51dfafe2ea42
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 24 13:55:23 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 6 16:20:27 2019 +0100

test: Fix metadata-zero-space with long VG names

---
 test/shell/metadata-zero-space.sh |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index f04de48..a7efdea 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -41,11 +41,13 @@ ls -l meta.txt
 head -n 100 meta.txt
 grep -A4 -B4 '01200:' meta.txt
 
-grep -B1 "$vg " meta.txt > meta.vg
+_vg="$vg "
+_vg="${_vg:0:16}"
+grep -B1 "$_vg" meta.txt > meta.vg
 
 cat meta.vg
 
-grep -v $vg meta.vg > meta.zeros
+grep -v "$_vg" meta.vg > meta.zeros
 
 cat meta.zeros
 
@@ -73,11 +75,11 @@ dd if="$dev1" of=meta.raw bs=1M seek=15 count=1
 
 xxd meta.raw > meta.txt
 
-grep -B1 "$vg " meta.txt > meta.vg
+grep -B1 "$_vg" meta.txt > meta.vg
 
 cat meta.vg
 
-grep -v $vg meta.vg > meta.zeros
+grep -v "$_vg" meta.vg > meta.zeros
 
 cat meta.zeros
 


