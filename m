From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Jan 2020 11:10:50 -0500
Subject: stable-2.02 - aux: writeerror_dev checks for delay target
Message-ID: <74954.120012111104500685@us-mta-100.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ab4d44a3b05cf77836b3be2c812a738131367ae
Commit:        5ab4d44a3b05cf77836b3be2c812a738131367ae
Parent:        f8ef0307372f13e1a5e74bd5741898f343c520bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 21 16:49:34 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 21 16:49:34 2020 +0100

aux: writeerror_dev  checks for delay target

---
 test/lib/aux.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b90063d..7a8d054 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1137,6 +1137,11 @@ writeerror_dev() {
 	local name=${PREFIX}-errordev
 
 	if test ! -e ERR_DEV; then
+		# delay target is used for error mapping
+		if test ! -f HAVE_DM_DELAY ; then
+			target_at_least dm-delay 1 1 0 || return 0
+			touch HAVE_DM_DELAY
+		fi
 		dmsetup create -u "TEST-$name" "$name" --table "0 4611686018427387904 error"
 		# Take major:minor of our error device
 		echo "$name" > ERR_DEV_NAME



