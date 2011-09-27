From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:19 +0200
Subject: [PATCH 05/16] fsadm: Add LVOL_PREFIX configuration option
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-6-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This commit adds new configuration option LVOL_PREFIX which defines a
prefix for new logical volumes. The prefix will be concatenated with a
sequential number of the logical volume.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index b374558..8a0364c 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -742,12 +742,10 @@ create() {
 		tmp=$(mktemp)
 		"$LVM" lvs "$vgname" --separator ' ' --noheadings > $tmp
 		for i in $(seq -w $MAX_VGS); do
-			"$GREP" -e " lvol${i} " $tmp &> /dev/null
-			if [ $? -ne 0 ]; then
-				name="lvol${i}"
-				lvname="--name $name"
-				break;
-			fi
+			"$GREP" -e " ${LVOL_PREFIX}${i} " $tmp &> /dev/null && continue
+			name="${LVOL_PREFIX}${i}"
+			lvname="--name $name"
+			break;
 		done
 		rm -f $tmp
 	fi
-- 
1.7.4.4


