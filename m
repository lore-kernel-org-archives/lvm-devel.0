From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Wed, 13 Sep 2023 11:45:45 +0000
Subject: [Git][lvmteam/lvm2][main] 3 commits: vdo: better support for devicesfile
Message-ID: <6501a0e9913f1_28a46f081a0@gitlab-sidekiq-low-urgency-cpu-bound-v2-fbd5468fb-2zggk.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
e1cfc075 by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
vdo: better support for devicesfile

Instead of relying on &#39;pvs&#39; output - check directly system
configuation and use lvmdevice accrording to use_devicesfile setting.

Also drop use of --fs ignore for filesystem extension for better
backward compatibility with older lvm version.

Shuffle code a bit so the &#39;--no-snapshot&#39; path does not execute
a few unnecessary commands.

- - - - -
e75ac1b4 by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
gcc: warning: missing braces around initializer

Fix warning emitted by some older gcc...

- - - - -
1885655e by Zdenek Kabelac at 2023-09-13T13:38:15+02:00
test: improve aux teardown

Handle the case of device teardown where the first pass
could have only a single, but opened device, for removal.
In such case we want to at least once go through
the udev_wait and retry removal again.

TODO: maybe a sleep .1  might be usable as well with udev_wait

- - - - -


3 changed files:

- scripts/lvm_import_vdo.sh
- test/lib/aux.sh
- tools/lvconvert.c


Changes:

=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -203,7 +203,7 @@ snapshot_merge_() {
 		error "ABORTING: Failed to initialize snapshot merge! Origin volume is unchanged."
 	}
 
-	verbose "Merging converted VDO volume..."
+	verbose "Merging converted VDO volume \"$VDO_DM_SNAPSHOT_NAME\"."
 	VDO_INCONSISTENT=1
 
 	# Running merging
@@ -235,12 +235,15 @@ snapshot_merge_() {
 	VDO_INCONSISTENT=
 	VDO_CONFIG_RESTORE=
 
+	verbose "Converted VDO volume is merged to \"$1\"."
+
 	"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
 		sleep 1 # sleep and retry once more
 		"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || {
 			error "ABORTING: Cannot remove snapshot $VDO_DM_SNAPSHOT_NAME! (check volume autoactivation...)"
 		}
 	}
+
 	VDO_DM_SNAPSHOT_NAME=
 	"$LOSETUP" -d "$VDO_SNAPSHOT_LOOP"
 	VDO_SNAPSHOT_LOOP=
@@ -500,44 +503,40 @@ convert_non_lv_() {
 	if [ "$vdo_logicalSizeRounded" -lt "$vdo_logicalSize" ]; then
 		# need to extend virtual size to be covering all the converted area
 		# let lvm2 to round to the proper virtual size of VDO LV
-		dry "$LVM" lvextend $YES $VERB --fs ignore --devices "$device" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
+		dry "$LVM" lvextend $YES $VERB --devices "$device" -L "$vdo_logicalSize"k "$VGNAME/$LVNAME"
 	fi
 
 	VDO_INCONSISTENT=
 
-	if [ -n "$USE_VDO_DM_SNAPSHOT" ]; then
-		dry "$LVM" vgchange -an $VERB $FORCE --devices "$device" "$VGNAME"
-
-		# Prevent unwanted auto activation when VG is merged
-		dry "$LVM" vgchange --setautoactivation n $VERB $FORCE --devices "$device" "$VGNAME"
-
-		if [ -z "$YES" ]; then
-			PROMPTING=yes
-			warn "Do not interrupt merging process once it starts (VDO data may become irrecoverable)!"
-			echo -n "$TOOL: Do you want to merge converted VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
-			read -r -n 1 -s ANSWER
-			case "${ANSWER:0:1}" in
-			  y|Y )  echo "Yes" ;;
-			    * )  echo "No" ; PROMPTING=""; return 1 ;;
-			esac
-			PROMPTING=""
-			YES="-y" # From now, now prompting
-		fi
+	[ -z "$USE_VDO_DM_SNAPSHOT" ] && return # no-snapshot case finished
 
-		dry snapshot_merge_ "$DEVICE"
+	dry "$LVM" vgchange -an $VERB $FORCE --devices "$device" "$VGNAME"
 
-		verbose "Merging of VDO device finished."
+	# Prevent unwanted auto activation when VG is merged
+	dry "$LVM" vgchange --setautoactivation n $VERB $FORCE --devices "$device" "$VGNAME"
+
+	if [ -z "$YES" ]; then
+		PROMPTING=yes
+		warn "Do not interrupt merging process once it starts (VDO data may become irrecoverable)!"
+		echo -n "$TOOL: Do you want to merge converted VDO device \"$DEVICE\" to VDO LV \"$VGNAME/$LVNAME\"? [y|N]: "
+		read -r -n 1 -s ANSWER
+		case "${ANSWER:0:1}" in
+		  y|Y )  echo "Yes" ;;
+		    * )  echo "No" ; PROMPTING=""; return 1 ;;
+		esac
+		PROMPTING=""
+		YES="-y" # From now, now prompting
 	fi
 
-	output=$("$LVM" pvs "$DEVICE" 2>&1) || {
-		if echo "$output" | grep -q "not in devices file" ; then
-			verbose "Adding \"$DEVICE\" to devices file."
-			dry "$LVM" lvmdevices --adddev "$DEVICE"
-		fi
-	}
+	dry snapshot_merge_ "$DEVICE"
+
+	# For systems using devicesfile add 'merged' PV into system.devices.
+	if [ "$("$LVM" lvmconfig --valuesonly devices/use_devicesfile --typeconfig full)" = "1" ]; then
+		dry "$LVM" lvmdevices --adddev "$DEVICE"
+	fi
 
 	# Restore auto activation for a VG
-	[ -n "$USE_VDO_DM_SNAPSHOT" ] && dry "$LVM" vgchange --setautoactivation y $VERB $FORCE "$VGNAME"
+	dry "$LVM" vgchange --setautoactivation y $VERB $FORCE "$VGNAME"
 
 	dry "$LVM" lvchange -ay $VERB $FORCE "$VGNAME/$LVNAME"
 }


=====================================
test/lib/aux.sh
=====================================
@@ -239,8 +239,8 @@ prepare_lvmpolld() {
 	echo $! > LOCAL_LVMPOLLD
 	for i in {200..0} ; do
 		test -e "$TESTDIR/lvmpolld.socket" && break
-		echo -n .;
-		sleep .1;
+		echo -n .
+		sleep .1
 	done # wait for the socket
 	test "$i" -gt 0 || die "Startup of lvmpolld is too slow."
 	echo ok
@@ -401,10 +401,10 @@ teardown_devs_prefixed() {
 	# 2nd. loop is trying --force removal which can possibly 'unstuck' some bloked operations
 	for i in 0 1; do
 		test "$i" = 1 && test "$stray" = 0 && break  # no stray device removal
+		local progress=1
 
 		while :; do
 			local sortby="name"
-			local progress=0
 
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
@@ -432,6 +432,7 @@ teardown_devs_prefixed() {
 
 			udev_wait
 			wait
+			progress=0
 		done # looping till there are some removed devices
 	done
 }


=====================================
tools/lvconvert.c
=====================================
@@ -6499,7 +6499,7 @@ static int _lvconvert_integrity_single(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct processing_handle *handle)
 {
-	struct integrity_settings settings = { 0 };
+	struct integrity_settings settings = { .tag_size = 0 };
 	int ret;
 
 	if (!integrity_mode_set(arg_str_value(cmd, raidintegritymode_ARG, NULL), &settings))



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/8cbfd72f6894fe8668477f96281eaecfadacb505...1885655e9a8fc305e70982b2e7992d06e7b0a474

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/8cbfd72f6894fe8668477f96281eaecfadacb505...1885655e9a8fc305e70982b2e7992d06e7b0a474
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230913/2f41b739/attachment-0001.htm>
