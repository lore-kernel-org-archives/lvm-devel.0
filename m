From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:38 +0200
Subject: [PATCH v3 05/18] fsadm: Add LVOL_PREFIX configuration option
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-6-git-send-email-lczerner@redhat.com>
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
index d1b17e5..d4901d1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -741,12 +741,10 @@ create() {
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


