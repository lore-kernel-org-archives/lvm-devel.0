From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:20 -0400
Subject: master - tests: correcting usage of $@
Message-ID: <201707101228.v6ACSK9B022066@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=91d6a62fc594152964ea25c44691c02ae23cdb9a
Commit:        91d6a62fc594152964ea25c44691c02ae23cdb9a
Parent:        f161c6ee9fad4d2ddefb97d4837d29360e5bc280
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 13:45:04 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: correcting usage of $@

Use "$@" (with quotes) to prevent whitespace problems.
---
 test/shell/lvcreate-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 375d4c0..27cce22 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -25,7 +25,7 @@ check_lv_field_modules_()
 	mod=$1
 	shift
 
-	for d in $*; do
+	for d in "$@"; do
 		check lv_field $vg/$d modules $mod
 	done
 }


