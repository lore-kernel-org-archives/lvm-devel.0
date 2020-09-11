From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 11 Sep 2020 19:53:50 +0000 (GMT)
Subject: master - tests: have_cache function checks for cache-pool
Message-ID: <20200911195350.DA4B0386F027@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f233d9a909a233c5147065bb5b17a2693622b281
Commit:        f233d9a909a233c5147065bb5b17a2693622b281
Parent:        77fdc17d70e62cab75efaaf0dad02493b948610d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 11:59:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:55 2020 +0200

tests: have_cache function checks for cache-pool

Check for cache-pool segment as plain cache can match writecache.
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1418bb473..364b80a5c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1625,7 +1625,7 @@ have_raid4 () {
 }
 
 have_cache() {
-	lvm segtypes 2>/dev/null | grep cache$ >/dev/null || {
+	lvm segtypes 2>/dev/null | grep ' cache-pool$' >/dev/null || {
 		echo "Cache is not built-in." >&2
 		return 1
 	}


