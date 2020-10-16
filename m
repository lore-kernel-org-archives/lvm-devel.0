From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:21 +0000 (GMT)
Subject: stable-2.02 - tests: missed char in list
Message-ID: <20201016191221.CE0AD396EC82@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d3e7266c76591be4b99487c2b1ea61ce525c074
Commit:        7d3e7266c76591be4b99487c2b1ea61ce525c074
Parent:        d1db024e169c3c6af08477524e8048d54b678714
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 17 10:41:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: missed char in list

'=' also doesn't belong to property name.
---
 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7235e69b8..0ab4cabaf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1360,7 +1360,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k[ =]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
+				grep "^$k[ \t=]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo


