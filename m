From: David Teigland <teigland@sourceware.org>
Date: Tue,  3 Jan 2023 17:43:53 +0000 (GMT)
Subject: main - lvresize: fix cryptsetup resize in helper
Message-ID: <20230103174353.4E9D83858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81acde7ffdf9fbe522ada16f89e429d9f729dc0c
Commit:        81acde7ffdf9fbe522ada16f89e429d9f729dc0c
Parent:        aec5e573afe610070eb2c6bed675d2a7c0efc7e8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 3 11:38:33 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 3 11:40:53 2023 -0600

lvresize: fix cryptsetup resize in helper

typo used "cryptresize" as command name

this affects cases where the file system is resized
independently, and then the lvresize command is used
which only needs to resize the crypt device and the LV.
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

