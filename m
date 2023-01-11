From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 11 Jan 2023 11:15:15 +0000 (GMT)
Subject: rhel-9.2.0 - lvresize: fix cryptsetup resize in helper
Message-ID: <20230111111515.7E1D43858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db067b9054d87ada6aa133394e65e3af9d75fc08
Commit:        db067b9054d87ada6aa133394e65e3af9d75fc08
Parent:        20c6961e37bf6f5010f9d2035dbc1ce03f9b0223
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 3 11:38:33 2023 -0600
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jan 6 15:38:29 2023 +0100

lvresize: fix cryptsetup resize in helper

typo used "cryptresize" as command name

this affects cases where the file system is resized
independently, and then the lvresize command is used
which only needs to resize the crypt device and the LV.

(cherry picked from commit 81acde7ffdf9fbe522ada16f89e429d9f729dc0c)
---
 scripts/lvresize_fs_helper.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvresize_fs_helper.sh b/scripts/lvresize_fs_helper.sh
index 031b8453b..f531dd447 100755
--- a/scripts/lvresize_fs_helper.sh
+++ b/scripts/lvresize_fs_helper.sh
@@ -224,7 +224,7 @@ fsreduce() {
 cryptresize() {
 	NEWSIZESECTORS=$(($NEWSIZEBYTES/512))
 	logmsg "cryptsetup resize ${NEWSIZESECTORS} sectors ${DEVPATH}"
-	cryptresize resize --size "$NEWSIZESECTORS" "$DEVPATH"
+	cryptsetup resize --size "$NEWSIZESECTORS" "$DEVPATH"
 	if [ $? -eq 0 ]; then
 		logmsg "cryptsetup done"
 	else

