From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:38 +0000 (UTC)
Subject: master - tests: add check grep_dmsetup
Message-ID: <20160919120138.D11266053F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=561f773bb47f11d495701e15d234c85cf746e285
Commit:        561f773bb47f11d495701e15d234c85cf746e285
Parent:        0e8449a5b921e60e6952ac5ff33e81a40abcd23a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 19 13:46:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

tests: add  check grep_dmsetup

Add simple helper/wrapper check function to check result
of dmsetup call i.e.:

check grep_dmsetup table vg-lv  "grep_expected"
check grep_dmsetup status vg-lv -v "grep_unexpected"
---
 test/lib/check.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 9dd8635..916d2df 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -400,6 +400,11 @@ raid_leg_status() {
 		die "$1-$2 status $val != $3  ($st)"
 }
 
+grep_dmsetup() {
+	dmsetup $1 $2 | tee out
+	grep "${@:3}" out || die "Expected output from dmsetup $1 not found!"
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"


