From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 14 Sep 2023 08:10:11 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: vdo: typo fix
Message-ID: <6502bfe3b51c4_28a4768558fc@gitlab-sidekiq-low-urgency-cpu-bound-v2-f6bdb45d-ttvfj.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
f5781144 by Zdenek Kabelac at 2023-09-14T10:01:43+02:00
vdo: typo fix

Argh - lastmin mods...

- - - - -
970e4d29 by Zdenek Kabelac at 2023-09-14T10:08:26+02:00
tests: add fsck after split

- - - - -


2 changed files:

- scripts/lvm_import_vdo.sh
- test/shell/caching-snapshot.sh


Changes:

=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -533,7 +533,7 @@ convert_non_lv_() {
 	# For systems using devicesfile add 'merged' PV into system.devices.
 	# Bypassing use of --valuesonly to keep compatibility with older lvm.
 	local usedev=$("$LVM" lvmconfig --typeconfig full devices/use_devicesfile || true)
-	[ "${usedev#*=" = "1" ] && dry "$LVM" lvmdevices --adddev "$DEVICE"
+	[ "${usedev#*=}" = "1" ] && dry "$LVM" lvmdevices --adddev "$DEVICE"
 
 	# Restore auto activation for a VG
 	dry "$LVM" vgchange --setautoactivation y $VERB $FORCE "$VGNAME"


=====================================
test/shell/caching-snapshot.sh
=====================================
@@ -94,6 +94,7 @@ test_snap_remove() {
 	lvcreate -s -L 32 -n snap $vg/$lv1
 	cp pattern1 "$mount_dir/pattern1b"
 	lvconvert --splitcache $vg/$lv1
+	fsck -n "$DM_DEV_DIR/$vg/snap"
 	mount "$DM_DEV_DIR/$vg/snap" "$mount_dir_snap"
 	not ls "$mount_dir_snap/pattern1b"
 	rm "$mount_dir/pattern1a"



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/9d7061f1a3b5795a4beccd0e285a5b9d32980a52...970e4d295eddb47d4540bb0762e35bd17b07841f

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/9d7061f1a3b5795a4beccd0e285a5b9d32980a52...970e4d295eddb47d4540bb0762e35bd17b07841f
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230914/1a667903/attachment.htm>
