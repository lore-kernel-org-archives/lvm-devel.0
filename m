From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:01 +0000 (UTC)
Subject: dev-prajnoha-report-select - tests: fix use of double apostrophes in get
Message-ID: <20140606120301.EEF4960F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21db25b3c41dec54da2a6975bf3f3f52b151f1e7
Commit:        21db25b3c41dec54da2a6975bf3f3f52b151f1e7
Parent:        1b59f5a99c351448c43f9d7e71ee3088bafcc6c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 13:05:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:34 2014 +0200

tests: fix use of double apostrophes in get

Need to put "" around parameters.
---
 test/lib/get.sh |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index babc4c9..b6fbf82 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -28,15 +28,18 @@ trim_() {
 }
 
 pv_field() {
-	trim_ "$(pvs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
+	local r=$(pvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	trim_ "$r"
 }
 
 vg_field() {
-	trim_ "$(vgs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
+	local r=$(vgs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	trim_ "$r"
 }
 
 lv_field() {
-	trim_ "$(lvs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
+	local r=$(lvs --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	trim_ "$r"
 }
 
 lv_devices() {


