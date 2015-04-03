From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 12:55:30 +0000 (UTC)
Subject: master - tests: hide unwanted output
Message-ID: <20150403125530.207C560353@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3a591a7b30baf00d2189638532d825f32a5b913
Commit:        d3a591a7b30baf00d2189638532d825f32a5b913
Parent:        dc418592202b05eb0643908d4167e7d634eeabd6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 14:38:22 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 14:54:22 2015 +0200

tests: hide unwanted output

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 677e486..7499aac 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -906,8 +906,8 @@ wait_pvmove_lv_ready() {
 	local retries=${2:-600}
 	while : ; do
 		test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
-		dmsetup info -c -o tables_loaded $1 > out || true;
-		not grep Live out || break
+		dmsetup info -c -o tables_loaded $1 > out 2>/dev/null|| true;
+		not grep Live out >/dev/null || break
 		sleep .1
 		retries=$((retries-1))
 	done


