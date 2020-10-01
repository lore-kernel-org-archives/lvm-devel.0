From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  1 Oct 2020 09:36:20 +0000 (GMT)
Subject: master - test: grep -q may fail and it does
Message-ID: <20201001093620.66C783850416@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46e5908759a803173c2d8964d8ca832195993f3b
Commit:        46e5908759a803173c2d8964d8ca832195993f3b
Parent:        2272a32e6f9b99f98514e58de82f8a3baa8b46da
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 1 11:33:57 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 1 11:33:57 2020 +0200

test: grep -q may fail and it does

The script runs with pipefail, grep -q exits immediately sending SIGPIPE
to lvm segtype which fails whole pipe.
---
 test/lib/aux.sh | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 77942009b..02989c5cb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1595,7 +1595,7 @@ have_thin() {
 }
 
 have_vdo() {
-	lvm segtypes 2>/dev/null | grep vdo$ >/dev/null || {
+	lvm segtypes 2>/dev/null | grep 'vdo$' >/dev/null || {
 		echo "VDO is not built-in." >&2
 		return 1
 	}
@@ -1603,7 +1603,7 @@ have_vdo() {
 }
 
 have_writecache() {
-	lvm segtypes 2>/dev/null | grep -q writecache$ || {
+	lvm segtypes 2>/dev/null | grep 'writecache$' >/dev/null || {
 		echo "writecache is not built-in." >&2
 		return 1
 	}
@@ -1611,7 +1611,7 @@ have_writecache() {
 }
 
 have_integrity() {
-	lvm segtypes 2>/dev/null | grep -q integrity$ || {
+	lvm segtypes 2>/dev/null | grep 'integrity$' >/dev/null || {
 		echo "integrity is not built-in." >&2
 		return 1
 	}


