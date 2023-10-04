From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 04 Oct 2023 23:15:42 +0000
Subject: [Git][lvmteam/lvm2][main] tests: previous patch wrongly replaced tab
Message-ID: <651df21ebfbe2_2aa5384570c2@gitlab-sidekiq-low-urgency-cpu-bound-v2-7dc44445b-hmxsb.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
bccfd92f by Zdenek Kabelac at 2023-10-05T01:11:54+02:00
tests: previous patch wrongly replaced tab

Tab overwrote first char instead of insert.
Actually it should be a single function.

- - - - -


1 changed file:

- test/shell/devicesfile-vpd-ids.sh


Changes:

=====================================
test/shell/devicesfile-vpd-ids.sh
=====================================
@@ -249,11 +249,11 @@ rm "$DF"
 aux wipefs_a "$DEV1"
 mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid" <<- EOF
-	431 302e 4154 4120 2020 2020 5642 4f58
-	048 4152 4444 4953 4b20 2020 2020 2020
-	020 2020 2020 2020 2020 2020 2020 2020
-	020 2020 5642 3963 3130 6433 3138 2d31
-	838 6439 6562 6320 0a
+	7431 302e 4154 4120 2020 2020 5642 4f58
+	2048 4152 4444 4953 4b20 2020 2020 2020
+	2020 2020 2020 2020 2020 2020 2020 2020
+	2020 2020 5642 3963 3130 6433 3138 2d31
+	3838 6439 6562 6320 0a
 EOF
 cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
@@ -276,11 +276,11 @@ rm "$DF"
 aux wipefs_a "$DEV1"
 mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid" <<- EOF
-	431 302e 4154 4120 2020 2020 5642 4f58
-	048 4152 4444 4953 4b20 2020 2020 2020
-	020 2020 2020 2020 2020 2020 2020 2020
-	020 2020 5642 3963 3130 6433 3138 2d31
-	838 6439 6562 6320 0a
+	7431 302e 4154 4120 2020 2020 5642 4f58
+	2048 4152 4444 4953 4b20 2020 2020 2020
+	2020 2020 2020 2020 2020 2020 2020 2020
+	2020 2020 5642 3963 3130 6433 3138 2d31
+	3838 6439 6562 6320 0a
 EOF
 cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 lvmdevices --adddev "$DEV1"
@@ -325,11 +325,11 @@ rm "$DF"
 aux wipefs_a "$DEV1"
 mkdir -p "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device"
 xxd -r -p > "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid" <<- EOF
-	431 302e 4154 4120 2020 2020 5642 4f58
-	048 4152 4444 4953 4b20 2020 2020 2020
-	020 2020 2020 2020 2020 2020 2020 2020
-	020 2020 5642 3963 3130 6433 3138 2d31
-	838 6439 6562 5f20 0a
+	7431 302e 4154 4120 2020 2020 5642 4f58
+	2048 4152 4444 4953 4b20 2020 2020 2020
+	2020 2020 2020 2020 2020 2020 2020 2020
+	2020 2020 5642 3963 3130 6433 3138 2d31
+	3838 6439 6562 5f20 0a
 EOF
 cat "$SYS_DIR/dev/block/$MAJOR1:$MINOR1/device/wwid"
 # The wwid has an actual underscore char (5f) followed by a space char (20)



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/bccfd92f4a0207dcfcb6c3da033f7ac5b2b4dd13

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/bccfd92f4a0207dcfcb6c3da033f7ac5b2b4dd13
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231004/181d3e3a/attachment-0001.htm>
