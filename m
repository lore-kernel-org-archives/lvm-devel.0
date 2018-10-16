From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 17:50:33 -0400
Subject: master - tests: fix conf generation with older shells
Message-ID: <201810162150.w9GLoXrF017353@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69bebfd9587e2db292051501d1a1e83d4f4564a5
Commit:        69bebfd9587e2db292051501d1a1e83d4f4564a5
Parent:        f1ac72c84804aa1c00aa385caec9eb007fd39aee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 23:44:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 23:49:35 2018 +0200

tests: fix conf generation with older shells

For shells without array support, fix selecting bug,
and require keyword to end with some 'space' char,
so  'scan' is not matched with  'scan_var'.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c3aeb43..c75ca6d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1213,7 +1213,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
+				grep "^$k[ \t]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo


