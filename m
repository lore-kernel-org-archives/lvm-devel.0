From: David Teigland <teigland@sourceware.org>
Date: Thu, 13 Jun 2019 12:37:42 -0400
Subject: master - tests: aux have_writecache
Message-ID: <201906131637.x5DGbgJQ009069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=208a09745db480d77120d0cd83743732fc216918
Commit:        208a09745db480d77120d0cd83743732fc216918
Parent:        7eaa3adedf4977352f93d8558dd0f1a0eb2c9921
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 13 11:36:18 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 13 11:36:18 2019 -0500

tests: aux have_writecache

function was never defined, causing writecache.sh to be skipped
---
 test/lib/aux.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 040c8f2..09ef9ed 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1478,6 +1478,14 @@ have_vdo() {
 	target_at_least dm-vdo "$@"
 }
 
+have_writecache() {
+	lvm segtypes 2>/dev/null | grep -q writecache$ || {
+		echo "writecache is not built-in." >&2
+		return 1
+	}
+	target_at_least dm-writecache "$@"
+}
+
 have_raid() {
 	target_at_least dm-raid "$@"
 


