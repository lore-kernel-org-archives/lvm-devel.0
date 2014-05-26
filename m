From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 May 2014 21:32:27 +0000 (UTC)
Subject: master - tests: update aux disable_dev
Message-ID: <20140526213227.0BE5C60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0ff3359f268913dbe01179600aa69c008cbb1ec
Commit:        b0ff3359f268913dbe01179600aa69c008cbb1ec
Parent:        49521f4e563fe0a19e70413f740e831f5fd16e16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 26 15:58:09 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 26 22:57:28 2014 +0200

tests: update aux disable_dev

disable_dev can't use transaction - since it may lead occasionaly to
weird error - example could be nomda-missing.sh test case.
Here occasionaly device instead of being removed was left as
error device and testing different code path (which is unfortunatelly
buggy)

When we want to test 'error' device -  'aux error_dev()' should be used.
---
 test/lib/aux.sh |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 07ba576..9a13cc8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -407,7 +407,6 @@ disable_dev() {
 	local dev
 
 	udev_wait
-	init_udev_transaction
 	for dev in "$@"; do
 		maj=$(($(stat -L --printf=0x%t "$dev")))
 		min=$(($(stat -L --printf=0x%T "$dev")))
@@ -415,7 +414,6 @@ disable_dev() {
 		dmsetup remove -f "$dev" 2>/dev/null || true
 		notify_lvmetad --major "$maj" --minor "$min"
 	done
-	finish_udev_transaction
 }
 
 enable_dev() {
@@ -699,7 +697,7 @@ raid456_replace_works() {
 	  3.6.*.fc18.i686*|3.6.*.fc18.x86_64) return 1 ;;
 	  3.9.*.fc19.i686*|3.9.*.fc19.x86_64) return 1 ;;
 	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
-	  3.1[0123].*.fc19.i686*|3.1[0123].*.fc19.x86_64) return 1 ;;
+	  3.1[01234].*.fc19.i686*|3.1[01234].*.fc19.x86_64) return 1 ;;
 	  3.13.*.fc20.i686*|3.13.*.fc20.x86_64) return 1 ;;
 	  3.14.*.fc21.i686*|3.14.*.fc21.x86_64) return 1 ;;
 	  3.15.*rc6*.fc21.i686*|3.15.*rc6*.fc21.x86_64) return 1 ;;


