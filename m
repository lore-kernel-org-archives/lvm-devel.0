From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:46 -0500
Subject: master - test: fail on device create
Message-ID: <81551.119121009464301725@us-mta-335.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b6defcf1fb20d3a9b2fb4f407e9abd4a8291bb0
Commit:        3b6defcf1fb20d3a9b2fb4f407e9abd4a8291bb0
Parent:        8ab1d489f3e3ab140f014d5b5a10859e396bce66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:30:55 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

test: fail on device create

Correct validation of prepared device and fail if the device can't
be created.
---
 test/lib/aux.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cbe0e21..ea126de 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -874,7 +874,11 @@ prepare_devs() {
 	wait
 	finish_udev_transaction
 
-	if test -f CREATE_FAILED -a -n "$LVM_TEST_BACKING_DEVICE"; then
+	if test -f CREATE_FAILED ; then
+		if test -z "$LVM_TEST_BACKING_DEVICE"; then
+			echo "failed"
+			return 1
+		fi
 		LVM_TEST_BACKING_DEVICE=
 		rm -f BACKING_DEV CREATE_FAILED
 		prepare_devs "$@"



