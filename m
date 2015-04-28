From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Apr 2015 09:36:40 +0000 (UTC)
Subject: master - tests: more descriptive aux
Message-ID: <20150428093640.6734561086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bb5b498f01db75822a861046ca934f50447eb05
Commit:        1bb5b498f01db75822a861046ca934f50447eb05
Parent:        a378e5a6dd3e8a2d8ccb69bb9f0acdd1e279b1dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 27 17:45:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 28 11:23:16 2015 +0200

tests: more descriptive aux

Tell what's reason of aux fail here.
---
 test/lib/aux.sh |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 95c2f73..1af43d0 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -951,14 +951,19 @@ target_at_least() {
 
 	local version=$(dmsetup targets 2>/dev/null | grep "${1##dm-} " 2>/dev/null)
 	version=${version##* v}
-	shift
 
-	version_at_least "$version" "$@"
+	version_at_least "$version" "${@:2}" || {
+		echo "Found $1 version $version, but requested ${*:2}." >&2
+		return 1
+	}
 }
 
 have_thin() {
-	test "$THIN" = shared -o "$THIN" = internal || return 1
-	target_at_least dm-thin-pool "$@" || return 1
+	test "$THIN" = shared -o "$THIN" = internal || {
+		echo "Thin is not built-in." >&2
+		return 1;
+	}
+	target_at_least dm-thin-pool "$@"
 
 	declare -a CONF
 	# disable thin_check if not present in system
@@ -978,12 +983,18 @@ have_thin() {
 }
 
 have_raid() {
-	test "$RAID" = shared -o "$RAID" = internal || return 1
+	test "$RAID" = shared -o "$RAID" = internal || {
+		echo "Raid is not built-in." >&2
+		return 1;
+	}
 	target_at_least dm-raid "$@"
 }
 
 have_cache() {
-	test "$CACHE" = shared -o "$CACHE" = internal || return 1
+	test "$CACHE" = shared -o "$CACHE" = internal || {
+		echo "Cache is not built-in." >&2
+		return 1;
+	}
 	target_at_least dm-cache "$@"
 
 	declare -a CONF


