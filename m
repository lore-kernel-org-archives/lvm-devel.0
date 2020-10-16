From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:19 +0000 (GMT)
Subject: stable-2.02 - tests: have_cache function checks for cache-pool
Message-ID: <20201016191119.085D6396EC06@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81538e6e50e66ba59eb39f42188b53e589dd6e7f
Commit:        81538e6e50e66ba59eb39f42188b53e589dd6e7f
Parent:        c563af047643b18b6ebc369a77ecf094dd2a5f11
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 11:59:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: have_cache function checks for cache-pool

Check for cache-pool segment as plain cache can match writecache.
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b5f81dc74..75dcbc41d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1637,7 +1637,7 @@ have_raid4 () {
 }
 
 have_cache() {
-	lvm segtypes 2>/dev/null | grep cache$ >/dev/null || {
+	lvm segtypes 2>/dev/null | grep ' cache-pool$' >/dev/null || {
 		echo "Cache is not built-in." >&2
 		return 1
 	}


