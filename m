From: David Teigland <teigland@sourceware.org>
Date: Thu,  3 Jun 2021 14:39:55 +0000 (GMT)
Subject: main - tests: Add checking for lvmlockd log
Message-ID: <20210603143955.097BA3838032@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b361b197e1a3fbbc5419b9c46f19539c2b7305c
Commit:        5b361b197e1a3fbbc5419b9c46f19539c2b7305c
Parent:        2097c27c05de30003850eb667b9cf21b3181fddf
Author:        Leo Yan <leo.yan@linaro.org>
AuthorDate:    Thu Jun 3 17:59:12 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 3 09:39:32 2021 -0500

tests: Add checking for lvmlockd log

Add checking for lvmlockd log, this can be used for the test cases which
are interested in the interaction with lvmlockd.

Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 test/lib/check.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 8493bde83..1f261940a 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -456,6 +456,11 @@ grep_dmsetup() {
 	grep -q "${@:3}" out || die "Expected output \"" "${@:3}" "\" from dmsetup $1 not found!"
 }
 
+grep_lvmlockd_dump() {
+	lvmlockctl --dump | tee out
+	grep -q "${@:1}" out || die "Expected output \"" "${@:1}" "\" from lvmlockctl --dump not found!"
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"


