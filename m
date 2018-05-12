From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 17:39:03 -0400
Subject: master - tests: aux detecs supported segments
Message-ID: <201805122139.w4CLd3cS005395@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b8b13c62b5407a9959bad2168c0c7dadfc80981
Commit:        7b8b13c62b5407a9959bad2168c0c7dadfc80981
Parent:        35ffc3f8eb7a326c29c1aa6349ac383d81f2cdc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 12 22:50:36 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 22:50:36 2018 +0200

tests: aux detecs supported segments

Replace previous compilation detection of present supported segtypes
with runtime check.
---
 test/lib/aux.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index adfad3b..0f0967b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1516,6 +1516,10 @@ driver_at_least() {
 }
 
 have_thin() {
+	lvm segtypes 2>/dev/null | grep -q thin$ || {
+		echo "Thin is not built-in." >&2
+		return 1
+	}
 	target_at_least dm-thin-pool "$@"
 
 	declare -a CONF=()
@@ -1556,6 +1560,10 @@ have_raid4 () {
 }
 
 have_cache() {
+	lvm segtypes 2>/dev/null | grep -q cache$ || {
+		echo "Cache is not built-in." >&2
+		return 1
+	}
 	target_at_least dm-cache "$@"
 
 	declare -a CONF=()


