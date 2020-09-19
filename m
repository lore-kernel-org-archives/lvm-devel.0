From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 15:39:13 +0000 (GMT)
Subject: master - tests: reduce disk usage
Message-ID: <20200919153913.C29B03857C40@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=530fc17b38b5363d5258d7ff5bc38f7863a585d6
Commit:        530fc17b38b5363d5258d7ff5bc38f7863a585d6
Parent:        1404e5ee61bdaddeb07a5e9ecfe1aad477cc9bf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 21:59:02 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 17:30:51 2020 +0200

tests: reduce disk usage

---
 test/shell/integrity.sh | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 6af12f23f..be435976e 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -115,10 +115,13 @@ _test_fs_with_raid() {
 
 	xxd "$dev1" > dev1.txt
 	tac dev1.txt > dev1.rev
+	rm -f dev1.txt
 	sed -e '0,/4242 4242 4242 4242 4242 4242 4242 4242/ s/4242 4242 4242 4242 4242 4242 4242 4242/4242 4242 4242 4242 4242 4242 4242 4243/' dev1.rev > dev1.rev.bad
+	rm -f dev1.rev
 	tac dev1.rev.bad > dev1.bad
+	rm -f dev1.rev.bad
 	xxd -r dev1.bad > "$dev1"
-	rm dev1.txt dev1.rev dev1.rev.bad dev1.bad
+	rm -f dev1.bad
 
 	lvchange -ay $vg/$lv1
 	mount "$DM_DEV_DIR/$vg/$lv1" $mnt


