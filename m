From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 24 Oct 2017 07:42:52 -0400
Subject: master - fsadm: add luks specific error message for small devices
Message-ID: <201710241142.v9OBgqoe031220@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6df7917581eea9eef3cf5144a870df9207be15df
Commit:        6df7917581eea9eef3cf5144a870df9207be15df
Parent:        888dd33148563e95b2b3faac98f6c6dd5f00a60a
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon Oct 23 15:31:44 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 24 13:40:50 2017 +0200

fsadm: add luks specific error message for small devices

---
 scripts/fsadm.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index a68c7b8..3d0fdcd 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -581,6 +581,10 @@ resize_luks() {
 		error "New size is not sector alligned"
 	fi
 
+	if [ $((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET)) -lt 1 ]; then
+		error "New size is smaller than minimum ($(((CRYPT_DATA_OFFSET + 1) * 512)) bytes) for LUKS device $VOLUME"
+	fi
+
 	NEWCBLOCKCOUNT=$((NEWBLOCKCOUNT - CRYPT_DATA_OFFSET))
 	NEWFSIZE=$(( NEWCBLOCKCOUNT * 512))
 


