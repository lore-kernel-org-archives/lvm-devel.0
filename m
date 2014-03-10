From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:31 +0000 (UTC)
Subject: master - tests: drop unused make_ioerror
Message-ID: <20140310112731.E31AB60F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c18fc42ecd2f33794fd552f1539d76867420cf5
Commit:        1c18fc42ecd2f33794fd552f1539d76867420cf5
Parent:        6cc75d149710aa0ffbdfe58e4abc92572cbed07a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 9 22:54:24 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:11 2014 +0100

tests: drop unused make_ioerror

---
 test/lib/aux.sh |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1426390..2cb3dc9 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -233,11 +233,6 @@ teardown() {
 	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -n "$RUNNING_DMEVENTD" || not pgrep dmeventd #&>/dev/null
 }
 
-make_ioerror() {
-	echo 0 10000000 error | dmsetup create -u ${PREFIX}-ioerror ioerror
-	ln -s "$DM_DEV_DIR/mapper/ioerror" "$DM_DEV_DIR/ioerror"
-}
-
 prepare_loop() {
 	local size=${1=32}
 	local i


