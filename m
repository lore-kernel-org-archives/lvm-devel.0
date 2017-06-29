From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:12 -0400
Subject: master - fsadm: no mixing string and array
Message-ID: <201706292025.v5TKPCE7025635@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=afded3e532546744793f2f483b2c86dfb4f05f9a
Commit:        afded3e532546744793f2f483b2c86dfb4f05f9a
Parent:        05a6d43476a4b2600329eae444c980107494b4ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 16:01:42 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

fsadm: no mixing string and array

Argument mixes string and array. Use * or separate argument.
---
 scripts/fsadm.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index b8744b1..0b248e1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -111,7 +111,7 @@ tool_usage() {
 }
 
 verbose() {
-	test -n "$VERB" && echo "$TOOL: $@" || true
+	test -n "$VERB" && echo "$TOOL:" "$@" || true
 }
 
 # Support multi-line error messages
@@ -124,10 +124,10 @@ error() {
 
 dry() {
 	if [ "$DRY" -ne 0 ]; then
-		verbose "Dry execution $@"
+		verbose "Dry execution" "$@"
 		return 0
 	fi
-	verbose "Executing $@"
+	verbose "Executing" "$@"
 	"$@"
 }
 
@@ -397,7 +397,7 @@ temp_umount() {
 }
 
 yes_no() {
-	echo -n "$@? [Y|n] "
+	echo -n "$@" "? [Y|n] "
 
 	if [ -n "$YES" ]; then
 		echo y ; return 0


