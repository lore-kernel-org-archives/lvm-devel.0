From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Oct 2019 10:51:01 -0400
Subject: master - tests: metadata-zero-space long vgnames
Message-ID: <201910161451.x9GEp1qw030216@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55bf692bff777e3beefed5b89a28c1fb1ebe1d32
Commit:        55bf692bff777e3beefed5b89a28c1fb1ebe1d32
Parent:        998e7b107513697b3ea966ba49aeef3fe115d908
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 16 09:46:48 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 16 09:46:48 2019 -0500

tests: metadata-zero-space long vgnames

In the hex dump output, grep for the vgname
followed by one space.  This allows for test pids
with up to seven digits, which are used to contruct
the variable vgname used by the test.  Otherwise
the long vgname wraps to the next line and fails to
match in grep.
---
 test/shell/metadata-zero-space.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index d037ab2..f04de48 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -39,9 +39,9 @@ xxd meta.raw > meta.txt
 # to help debug if the next grep fails
 ls -l meta.txt
 head -n 100 meta.txt
-grep -A4 -B4 1200 meta.txt
+grep -A4 -B4 '01200:' meta.txt
 
-grep -B1 "$vg {" meta.txt > meta.vg
+grep -B1 "$vg " meta.txt > meta.vg
 
 cat meta.vg
 
@@ -73,7 +73,7 @@ dd if="$dev1" of=meta.raw bs=1M seek=15 count=1
 
 xxd meta.raw > meta.txt
 
-grep -B1 "$vg {" meta.txt > meta.vg
+grep -B1 "$vg " meta.txt > meta.vg
 
 cat meta.vg
 


