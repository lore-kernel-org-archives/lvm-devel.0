From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:18 +0200
Subject: [PATCH 04/16] fsadm: Use DEFAULT_DEVICE_POOL when creating volume group
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-5-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I user did not specified group, use DEFAULT_DEVICE_POOL from configuration
file.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   58 +++--------------------------------------------------
 1 files changed, 4 insertions(+), 54 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index bc8e91f..b374558 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -717,49 +717,10 @@ create() {
 		vgname=$GROUP
 	fi
 
-	# Devices are not in any group so we should find some.
-	# Either create a new one, or use the existing one, if
-	# there is only one vgroup, or use the one with enough
-	# free space in it
 	if [ -z "$vgname" ]; then
-		vgroups=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units k 2> /dev/null)
-		lines=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units k 2> /dev/null | wc -l)
-
-		if [ $lines -eq 1 ]; then
-			vgname=$(echo $vgroups | sed -e 's/^ *//' | cut -d' ' -f1)
-		elif [ $lines -gt 1 ]; then
-			if [ -z $size ]; then
-				error "Not enough information to create" \
-					"logical volume"
-			fi
-			decode_size $size 1
-			new_size=$NEWBLOCKCOUNT
-			IFS=$NL
-			for i in $vgroups; do
-				vgsize=$(echo $i | sed -e 's/^ *//' | cut -d' ' -f2)
-				vgsize=${vgsize%%B}
-				if [ $vgsize -ge $new_size ]; then
-					vgname=$(echo $i | sed -e 's/^ *//' | cut -d' ' -f1)
-					break;
-				fi
-			done
-		fi
+		vgname=$DEFAULT_DEVICE_POOL
+		"$LVM" vgs "$vgname" &> /dev/null || vg_create=1
 	fi
-	IFS=$IFS_OLD
-
-	if [ -z "$vgname" ]; then
-		[ $devcount -eq 0 ] && error "No suitable device specified."
-		for i in $(seq -w $MAX_VGS); do
-			"$LVM" vgs vg${i} &> /dev/null
-			if [ $? -ne 0 ]; then
-				vgname="vg${i}"
-				break;
-			fi
-		done
-		vg_create=1
-	fi
-
-	[ -z "$vgname" ] && error "No suitable name for volume group found."
 
 	if [ "$stripesize" ] || [ "$stripes" ]; then
 		if [ -z "$stripes" ] && [ $devcount -eq 0 ]; then
@@ -1193,19 +1154,8 @@ add() {
 	"$LVM" vgs -o vg_name --separator ' ' --noheadings | sed -e 's/^ *//' > $tmp
 
 	if [ -z "$vgname" ]; then
-		lines=$(wc -l $tmp)
-		lines=${lines%% *}
-
-		if [ $lines -eq 1 ]; then
-			vgname=$(cut -d' ' -f1 $tmp)
-		elif [ $lines -gt 1 ]; then
-			list_pool
-			rm -f $tmp
-			error "Please, specify group you want to add the device into"
-		elif [ $lines -eq 0 ]; then
-			vgname="vg001"
-			vg_create=1
-		fi
+		vgname=$DEFAULT_DEVICE_POOL
+		"$GREP" "$vgname" $tmp &> /dev/null || vg_create=1
 	else
 		"$GREP" -e "$vgname" $tmp &> /dev/null
 		vg_create=$?
-- 
1.7.4.4


