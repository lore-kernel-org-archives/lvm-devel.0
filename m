From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:15 +0000 (GMT)
Subject: dev-next - tests: aux fix check_lvmpolld_init_rq_count
Message-ID: <20210331214915.8EC983858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0558b223b87b922faa709e7a7e0e6aaa4b7f0c42
Commit:        0558b223b87b922faa709e7a7e0e6aaa4b7f0c42
Parent:        73710b87fb567e3d6d72b475afe9f95ccc0afad6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 00:33:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 00:33:21 2021 +0100

tests: aux fix check_lvmpolld_init_rq_count

Make check_lvmpolld_init_rq_count() more compatible with older gawk,
where some functionality was not working properly.
Also change 'not not' condition.
---
 test/lib/aux.sh | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6c43790b7..6cf86bc38 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1743,11 +1743,11 @@ dmsetup_wrapped() {
 awk_parse_init_count_in_lvmpolld_dump() {
 	printf '%s' \
 	\
-	$'BEGINFILE { x=0; answ=0; FS="="; key="[[:space:]]*"vkey }' \
+	$'BEGINFILE { x=0; answ=0 }' \
 	$'{' \
 		$'if (/.*{$/) { x++ }' \
 		$'else if (/.*}$/) { x-- }' \
-		$'else if ( x == 2 && $1 ~ key) { value=substr($2, 2); value=substr(value, 1, length(value) - 1); }' \
+		$'else if ( x == 2 && $1 ~ "[[:space:]]*"vkey) { value=substr($2, 2); value=substr(value, 1, length(value) - 1); }' \
 		$'if ( x == 2 && value == vvalue && $1 ~ /[[:space:]]*init_requests_count/) { answ=$2 }' \
 		$'if (answ > 0) { exit 0 }' \
 	$'}' \
@@ -1756,7 +1756,7 @@ awk_parse_init_count_in_lvmpolld_dump() {
 
 check_lvmpolld_init_rq_count() {
 	local ret
-	ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
+	ret=$(awk -v vvalue="$2" -v vkey="${3:-lvname}" -F= "$(awk_parse_init_count_in_lvmpolld_dump)" lvmpolld_dump.txt)
 	test "$ret" -eq "$1" || {
 		die "check_lvmpolld_init_rq_count failed. Expected $1, got $ret"
 	}
@@ -1779,7 +1779,7 @@ wait_pvmove_lv_ready() {
 			}
 			test -z "$lvid" || {
 				lvmpolld_dump > lvmpolld_dump.txt
-				! check_lvmpolld_init_rq_count 1 "$lvid" lvid || break;
+				check_lvmpolld_init_rq_count 1 "$lvid" lvid && break;
 			}
 			sleep .1
 			retries=$((retries-1))


