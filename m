From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:16 +0200
Subject: [PATCH 02/16] fsadm: Make all internal math in kilobytes
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-3-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should make all math in fsadm to count with kilobytes (if possible)
because it will bypass the problem of having too big numbers. Also the
smaller granularity might have troubles with 512B alignment.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   79 ++++++++++++++++++++++++++---------------------------
 1 files changed, 39 insertions(+), 40 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4a9477d..e982b88 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -188,15 +188,14 @@ humanize_size() {
 		count=$(($count+1))
 	done
 	case $count in
-		0) unit="B" ;;
-		1) unit="KiB" ;;
-		2) unit="MiB" ;;
-		3) unit="GiB" ;;
-		4) unit="TiB" ;;
-		5) unit="PiB" ;;
-		6) unit="EiB" ;;
-		7) unit="ZiB" ;;
-		8) unit="YiB" ;;
+		0) unit="KiB" ;;
+		1) unit="MiB" ;;
+		2) unit="GiB" ;;
+		3) unit="TiB" ;;
+		4) unit="PiB" ;;
+		5) unit="EiB" ;;
+		6) unit="ZiB" ;;
+		7) unit="YiB" ;;
 		*) unit="???" ;;
 	esac
 	echo "$size $unit"
@@ -217,11 +216,11 @@ get_ext_size() {
 		esac
 	done
 
-	total=$(($bcount*$bsize))
+	total=$(($bcount*$bsize/1024))
 	TOTAL=$(humanize_size $total)
-	used=$((($bcount-$fbcount)*$bsize))
+	used=$((($bcount-$fbcount)*$bsize/1024))
 	USED=$(humanize_size $used)
-	free=$((($fbcount-$rbcount)*$bsize))
+	free=$((($fbcount-$rbcount)*$bsize/1024))
 	FREE=$(humanize_size $free)
 }
 
@@ -247,11 +246,11 @@ get_xfs_size() {
 		bcount=$(($bcount-$lbcount))
 		fbcount=$(($fbcount-(4+(4*$agcount))))
 
-		total=$(($bcount*$bsize))
+		total=$(($bcount*$bsize/1024))
 		TOTAL=$(humanize_size $total)
-		used=$((($bcount-$fbcount)*$bsize))
+		used=$((($bcount-$fbcount)*$bsize/1024))
 		USED=$(humanize_size $used)
-		free=$(($fbcount*$bsize))
+		free=$(($fbcount*$bsize/1024))
 		FREE=$(humanize_size $free)
 		return
 	fi
@@ -278,21 +277,20 @@ detect_fs_size() {
 }
 
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks
-# (2^(60/50/40/30/20/10/0))
+# (2^(60/50/40/30/20/10/0)) into Kilobytes (KiB)
 decode_size() {
 	case "$1" in
-	 *[eE]) NEWSIZE=$(float_math "${1%[eE]} * 1152921504606846976") ;;
-	 *[pP]) NEWSIZE=$(float_math "${1%[pP]} * 1125899906842624") ;;
-	 *[tT]) NEWSIZE=$(float_math "${1%[tT]} * 1099511627776") ;;
-	 *[gG]) NEWSIZE=$(float_math "${1%[gG]} * 1073741824") ;;
-	 *[mM]) NEWSIZE=$(float_math "${1%[mM]} * 1048576") ;;
-	 *[kK]) NEWSIZE=$(float_math "${1%[kK]} * 1024") ;;
-	 *[bB]) NEWSIZE=${1%[bB]} ;;
-	     *) NEWSIZE=$(( $1 * $2 )) ;;
+	 *[eE]) NEWSIZE=$(float_math "${1%[eE]} * 1125899906842624") ;;
+	 *[pP]) NEWSIZE=$(float_math "${1%[pP]} * 1099511627776") ;;
+	 *[tT]) NEWSIZE=$(float_math "${1%[tT]} * 1073741824") ;;
+	 *[gG]) NEWSIZE=$(float_math "${1%[gG]} * 1048576") ;;
+	 *[mM]) NEWSIZE=$(float_math "${1%[mM]} * 1024") ;;
+	 *[kK]) NEWSIZE=${1%[kK]} ;;
+	 *[bB]) NEWSIZE=$(float_math "${1%[bB]} / 1024") ;;
 	esac
 
 	NEWSIZE=${NEWSIZE%%.*}
-	NEWBLOCKCOUNT=$(float_math "$NEWSIZE / $2")
+	NEWBLOCKCOUNT=$(float_math "($NEWSIZE / $2) * 1024")
 	NEWBLOCKCOUNT=${NEWBLOCKCOUNT%%.*}
 }
 
@@ -428,8 +426,8 @@ resize_ext() {
 		esac
 	fi
 
-	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE bytes ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
-	dry "$RESIZE_EXT" "$FSFORCE" "$VOLUME" "$NEWBLOCKCOUNT"
+	verbose "Resizing filesystem on device \"$VOLUME\" to $NEWSIZE KiB ($BLOCKCOUNT -> $NEWBLOCKCOUNT blocks of $BLOCKSIZE bytes)"
+	dry "$RESIZE_EXT" $FSFORCE "$VOLUME" "$NEWBLOCKCOUNT"
 }
 
 #############################
@@ -449,11 +447,11 @@ resize_reiser() {
 	done
 	validate_parsing "$TUNE_REISER"
 	decode_size $1 $BLOCKSIZE
-	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE bytes, bs: $NEWBLOCKCOUNT)"
+	verbose "Resizing \"$VOLUME\" $BLOCKCOUNT -> $NEWBLOCKCOUNT blocks ($NEWSIZE KiB, bs: $NEWBLOCKCOUNT)"
 	if [ -n "$YES" ]; then
-		echo y | dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
+		echo y | dry "$RESIZE_REISER" -s "${NEWSIZE}K" "$VOLUME"
 	else
-		dry "$RESIZE_REISER" -s "$NEWSIZE" "$VOLUME"
+		dry "$RESIZE_REISER" -s "${NEWSIZE}K" "$VOLUME"
 	fi
 }
 
@@ -547,9 +545,10 @@ resize_fs() {
 resize_lvolume() {
 	lvname=$1
 	newsize=$2
-	lvsize=$(LANG=C "$LVM" lvs -o lv_size --separator ' ' --noheadings --nosuffix --units b $lvname 2> /dev/null | sed -e 's/^ *//')
+
+	lvsize=$(LANG=C "$LVM" lvs -o lv_size --separator ' ' --noheadings --nosuffix --units k $lvname 2> /dev/null | sed -e 's/^ *//')
 	if [ $lvsize != $newsize ]; then
-		dry "$LVM" lvresize "$VERB" "$FORCE" -L"${newsize}"b "$lvname"
+		dry "$LVM" lvresize "$VERB" "$FORCE" -L "${newsize}k" "$lvname"
 	else
 		verbose "Logical volume already is of the size you're trying to resize it to"
 	fi
@@ -720,8 +719,8 @@ create() {
 	# there is only one vgroup, or use the one with enough
 	# free space in it
 	if [ -z "$vgname" ]; then
-		vgroups=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units b 2> /dev/null)
-		lines=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units b 2> /dev/null | wc -l)
+		vgroups=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units k 2> /dev/null)
+		lines=$("$LVM" vgs -o vg_name,vg_free --separator ' ' --noheadings --units k 2> /dev/null | wc -l)
 
 		if [ $lines -eq 1 ]; then
 			vgname=$(echo $vgroups | sed -e 's/^ *//' | cut -d' ' -f1)
@@ -904,7 +903,7 @@ remove() {
 		echo "Usage: $TOOL remove [mount point | dm device | voulume group | device | --all]"
 		exit 0
 	elif [ "$1" == "--all" ]; then
-		list="$(LANG=C $LVM vgs -o vg_name --separator ' ' --noheadings --nosuffix --units b 2> /dev/null)"
+		list="$(LANG=C $LVM vgs -o vg_name --separator ' ' --noheadings --nosuffix --units k 2> /dev/null)"
 	else
 		list="$@"
 	fi
@@ -921,7 +920,7 @@ remove() {
 list_filesystems() {
 	local IFS=$NL
 	local c=0
-	for line in $(LANG=C "$LVM" lvs -o lv_path,lv_size,segtype --noheadings --separator ' ' --nosuffix --units b 2> /dev/null); do
+	for line in $(LANG=C "$LVM" lvs -o lv_path,lv_size,segtype --noheadings --separator ' ' --nosuffix --units k 2> /dev/null); do
 		line=$(echo $line | sed -e 's/^ *\//\//')
 		volume=$(echo $line | cut -d' ' -f1)
 		[ "$volume" == "$last_volume" ] && continue
@@ -1004,11 +1003,11 @@ list_devices() {
 	c=0
 	dmnumber=$(cat "$PROCDEVICES" | "$GREP" device-mapper | sed -e 's/^  *//')
 	dmnumber=${dmnumber%% *}
-	LANG=C "$LVM" pvs -o pv_name,vg_name,pv_size,pv_free,pv_used --separator ' ' --noheadings --nosuffix --units b > $tmp
-	for line in $(cat "$PROCPARTITIONS" | tail -n +3 | sed -e 's/^  *//' | "$GREP" -v -e "^$dmnumber"); do
+	LANG=C "$LVM" pvs -o pv_name,vg_name,pv_size,pv_free,pv_used --separator ' ' --noheadings --nosuffix --units k > $tmp
+	for line in $(cat "$PROCPARTITIONS" | tail -n +3 | sed -e 's/^  *//' | grep -v -e "^$dmnumber"); do
 		c=$((c+1))
 		line=$(echo $line | sed -e 's/  */ /g')
-		_total=$(($(echo $line | cut -d' ' -f3)*1024))
+		_total=$(echo $line | cut -d' ' -f3)
 		local total[$c]=$(humanize_size ${_total%%.*})
 		VOLUME=$(echo $line | cut -d' ' -f4)
 		RVOLUME="/dev/$(echo $line | cut -d' ' -f4)"
@@ -1087,7 +1086,7 @@ list_devices() {
 list_pool() {
 	local IFS=$NL
 	c=0
-	for line in $(LANG=C "$LVM" vgs -o vg_name,pv_count,vg_size,vg_free --separator ' ' --noheadings --nosuffix --units b 2> /dev/null); do
+	for line in $(LANG=C "$LVM" vgs -o vg_name,pv_count,vg_size,vg_free --separator ' ' --noheadings --nosuffix --units k 2> /dev/null); do
 		c=$((c+1))
 		line=$(echo $line | sed -e 's/^ *//')
 		local group[$c]=$(echo $line | cut -d' ' -f1)
-- 
1.7.4.4


