From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:58 -0400
Subject: master - tests: shellcheck split assing
Message-ID: <201803231625.w2NGPw8w031987@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1507956383b9b28e52051ecf56d754e8cda6e025
Commit:        1507956383b9b28e52051ecf56d754e8cda6e025
Parent:        397b7891ff79ba7c31040c31c17aa8587e78a9a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 17:03:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

tests: shellcheck split assing

Keep possibly error unmasked by assign
---
 test/lib/aux.sh |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f8fb8a3..4269987 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1107,7 +1107,9 @@ prepare_vg() {
 }
 
 extend_filter() {
-	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter
+
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for rx in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"$rx\", :")
 	done
@@ -1119,7 +1121,9 @@ extend_filter_LVMTEST() {
 }
 
 hide_dev() {
-	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter
+
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\\[:[ \"r|$dev|\", :")
 	done
@@ -1127,7 +1131,9 @@ hide_dev() {
 }
 
 unhide_dev() {
-	local filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
+	local filter
+
+	filter=$(grep ^devices/global_filter CONFIG_VALUES | tail -n 1)
 	for dev in "$@"; do
 		filter=$(echo "$filter" | sed -e "s:\"r|$dev|\", ::")
 	done


