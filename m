From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 15:18:35 +0000 (UTC)
Subject: master - tests: better check for empty set
Message-ID: <20150403151835.AAC0160AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93ab6d51844352d8680d62e68da7973c4bf98346
Commit:        93ab6d51844352d8680d62e68da7973c4bf98346
Parent:        ce3c61c4af4622674d8ebd4301d4fd24c4cb8886
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 16:38:05 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 16:38:05 2015 +0200

tests: better check for empty set

Even when no arg is passed - there is still one "" arg there...
So taky it easy and check for empty string instead.
---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7499aac..f4fc1b5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -431,10 +431,10 @@ common_dev_() {
 		if test "$read_ms" -eq 0 -a "$write_ms" -eq 0 ; then
 			offsets=
 		else
-			test ${#offsets[@]} -eq 0 && offsets="0:"
+			test -z "${offsets[@]}" && offsets="0:"
 		fi ;;
 	error)  offsets=${@:3}
-		test ${#offsets[@]} -eq 0 && offsets="0:" ;;
+		test -z "${offsets[@]}" && offsets="0:" ;;
 	esac
 
 	local pos


