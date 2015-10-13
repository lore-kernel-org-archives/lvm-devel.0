From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:36 +0000 (UTC)
Subject: master - tests: show status in in_sync
Message-ID: <20151013140436.EC2E96017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2cb1f6eafeb72dcd49a7ed941d9c5400540284fa
Commit:        2cb1f6eafeb72dcd49a7ed941d9c5400540284fa
Parent:        93229184066a9b7726e3b572bca3f612ed2815fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 7 15:07:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:20 2015 +0200

tests: show status in in_sync

Make visible actual status line when returing 'raid' is in sync.
Useful to prove when kernel is wrong.
---
 test/lib/check.sh |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index b47bc8b..74a6eb6 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -189,16 +189,17 @@ in_sync() {
 	local lvm_name="$1/$2"
 	local dm_name=$(echo $lvm_name | sed s:-:--: | sed s:/:-:)
 
-	if ! a=(`dmsetup status $dm_name`); then
+	a=( $(dmsetup status $dm_name) )  || \
 		die "Unable to get sync status of $1"
-	elif [ ${a[2]} = "snapshot-origin" ]; then
-		if ! a=(`dmsetup status ${dm_name}-real`); then
+
+	if [ ${a[2]} = "snapshot-origin" ]; then
+		a=( $(dmsetup status ${dm_name}-real) ) || \
 			die "Unable to get sync status of $1"
-		fi
 		snap=": under snapshot"
 	fi
 
-	if [ ${a[2]} = "raid" ]; then
+	case ${a[2]} in
+	"raid")
 		# 6th argument is the sync ratio for RAID
 		idx=6
 		type=${a[3]}
@@ -206,13 +207,16 @@ in_sync() {
 			echo "$lvm_name ($type$snap) is not in-sync"
 			return 1
 		fi
-	elif [ ${a[2]} = "mirror" ]; then
+		;;
+	"mirror")
 		# 4th Arg tells us how far to the sync ratio
 		idx=$((${a[3]} + 4))
 		type=${a[2]}
-	else
+		;;
+	*)
 		die "Unable to get sync ratio for target type '${a[2]}'"
-	fi
+		;;
+	esac
 
 	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
 
@@ -221,11 +225,10 @@ in_sync() {
 		return 1
 	fi
 
-	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
+	[[ ${a[$(($idx - 1))]} =~ a ]] && \
 		die "$lvm_name ($type$snap) in-sync, but 'a' characters in health status"
-	fi
 
-	echo "$lvm_name ($type$snap) is in-sync"
+	echo "$lvm_name ($type$snap) is in-sync \"${a[@]}\""
 }
 
 active() {


