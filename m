From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Jun 2019 18:06:20 -0400
Subject: stable-2.02 - aux: fix selecting lvmconf values
Message-ID: <201906192206.x5JM6KTf013884@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a311684c4ab0ec2cf3a3d11412295da52df63c88
Commit:        a311684c4ab0ec2cf3a3d11412295da52df63c88
Parent:        f3a87a2c2e339328ea4d7448f43d5317806a6b24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 19 23:55:44 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 00:05:46 2019 +0200

aux: fix selecting lvmconf values

For older bashes (i.e. rhel5) code can't use internal bash arrays
and uses old-school greps and sorts to create configuration file.
But the split of value was mismatching names with same prefix
so  i.e.

devices/scan
devices/scan_lvs

was matching always the later one - fix this by expecting
whitespace or '=' after the name.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 86ed554..1db6fbf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1296,7 +1296,7 @@ EOF
 			echo "$s {"
 			local k
 			for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-				grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
+				grep "^$k[ =]" "$config_values" | tail -n 1 | sed -e "s,^$s/,	 ," || true
 			done
 			echo "}"
 			echo


