From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Oct 2018 05:23:21 -0400
Subject: master - tests: missed char in list
Message-ID: <201810170923.w9H9NLRl019550@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e1ee07d696fb0a1771f7dcd4490ed9ace0fa8d6
Commit:        9e1ee07d696fb0a1771f7dcd4490ed9ace0fa8d6
Parent:        015231b11ffedc8e44d74ef3a5204f1e99fc6813
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 17 10:41:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 17 10:41:25 2018 +0200

tests: missed char in list

'=' also doesn't belong to property name.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c75ca6d..a11eb3f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1213,7 +1213,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k[ \t]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
+				grep "^$k[ \t=]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo


