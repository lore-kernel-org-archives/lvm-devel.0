From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:51 -0400
Subject: master - tests: check.sh eliminate useless cat
Message-ID: <201706292028.v5TKSpOo026868@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b45ca523ecbba006d2982ae085140c69edbe084e
Commit:        b45ca523ecbba006d2982ae085140c69edbe084e
Parent:        51237cb5047a93382f8d239e9aa9d3899154300f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 11:56:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh eliminate useless cat

Useless cat. Consider 'cmd < file | ..' or 'cmd file | ..' instead.
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 64019da..a43aef7 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -49,7 +49,7 @@ mirror_images_redundant() {
 
 	(grep -v ^# check.tmp.all || true) | sort | uniq -d > check.tmp
 
-	test "$(cat check.tmp | wc -l)" -eq 0 || \
+	test "$(wc -l < check.tmp)" -eq 0 || \
 		die "mirror images of $lv expected redundant, but are not:" \
 			"$(cat check.tmp.all)"
 }


