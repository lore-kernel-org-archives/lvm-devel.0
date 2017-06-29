From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:34 -0400
Subject: master - tests: check.sh no mixing string
Message-ID: <201706292028.v5TKSY74026822@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=824db54128ef6831629d86ef3b472164048fc227
Commit:        824db54128ef6831629d86ef3b472164048fc227
Parent:        810f856c2490eb1d5db858f26a26621c4a3477e0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 08:40:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: check.sh no mixing string

Argument mixes string and array. Use * or separate argument.
---
 test/lib/check.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 0ad48a9..6f56ea3 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -237,7 +237,7 @@ in_sync() {
 		return 1
 	fi
 
-	echo "$lvm_name ($type$snap) is in-sync \"${a[@]}\""
+	echo "$lvm_name ($type$snap) is in-sync" "${a[@]}"
 }
 
 active() {
@@ -434,7 +434,7 @@ raid_leg_status() {
 
 grep_dmsetup() {
 	dmsetup "$1" "$2" | tee out
-	grep -q "${@:3}" out || die "Expected output \"${@:3}\" from dmsetup $1 not found!"
+	grep -q "${@:3}" out || die "Expected output \"" "${@:3}" "\" from dmsetup $1 not found!"
 }
 
 #set -x


