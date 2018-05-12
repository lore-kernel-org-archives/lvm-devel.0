From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:33 -0400
Subject: master - tests: drop cache checking
Message-ID: <201805121626.w4CGQXVt008335@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b465d1543a46ba3994a0a53a08592f7a2838d35
Commit:        0b465d1543a46ba3994a0a53a08592f7a2838d35
Parent:        d38a2d64f0cddc951774b63d56b2fb5d9afb336e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:53:41 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

tests: drop cache checking

Just like 52656c89fd6e7655b0599e20f90cc9d70561f1fb
when now cache is compiled in 'unditionally'.

This patch is actually enforce by changes in
commit: 2bc896f2a3a0023a4f45f10da3d0a22295a633ee
where CACHE value is not set anymore.
---
 test/lib/aux.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 977e917..adfad3b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1556,10 +1556,6 @@ have_raid4 () {
 }
 
 have_cache() {
-	test "$CACHE" = shared -o "$CACHE" = internal || {
-		echo "Cache is not built-in." >&2
-		return 1;
-	}
 	target_at_least dm-cache "$@"
 
 	declare -a CONF=()


