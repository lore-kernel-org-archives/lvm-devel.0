From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:37 -0400
Subject: master - tests: check.sh using grep -F
Message-ID: <201706292028.v5TKSbBF026833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c0197040a5c68af8314b5466c8b1f61b381044f6
Commit:        c0197040a5c68af8314b5466c8b1f61b381044f6
Parent:        824db54128ef6831629d86ef3b472164048fc227
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 08:41:43 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh using grep -F

fgrep is non-standard and deprecated. Use grep -F instead.
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 6f56ea3..1ec1bab 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -148,7 +148,7 @@ mirror_nonredundant() {
 	attr=$(get lv_field "$lv" attr)
 	(echo "$attr" | grep "^......m...$" >/dev/null) || {
 		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
-		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
+		   lvs -a | grep -F "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else


