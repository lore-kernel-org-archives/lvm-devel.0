From: Leo Yan <leo.yan@linaro.org>
Date: Thu,  3 Jun 2021 17:59:12 +0800
Subject: [PATCH v1 04/17] tests: Add checking for lvmlockd log
In-Reply-To: <20210603095925.510302-1-leo.yan@linaro.org>
References: <20210603095925.510302-1-leo.yan@linaro.org>
Message-ID: <20210603095925.510302-5-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
-- 
2.25.1


