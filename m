From: Ondrej Kozina <okozina@sourceware.org>
Date: Tue, 10 Oct 2017 09:52:04 -0400
Subject: master - fsadm: minor fixes for crypt support
Message-ID: <201710101352.v9ADq44K014883@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59145715f12c65bca68d28bd7e04e660752d6760
Commit:        59145715f12c65bca68d28bd7e04e660752d6760
Parent:        27ef503b35daf63b5cf8c1af3b009abe61335759
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Oct 10 15:21:28 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Oct 10 15:21:35 2017 +0200

fsadm: minor fixes for crypt support

drop useless asterisk expansion
enforce matching string prefix by adding ^
---
 scripts/fsadm.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index da687fd..a0a75b6 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -548,9 +548,9 @@ detect_luks_device() {
 		return
 	fi
 
-	_LUKS_UUID="CRYPT-LUKS$_LUKS_VERSION-${_LUKS_UUID//[UID:[:space:]-]/}-*"
+	_LUKS_UUID="CRYPT-LUKS$_LUKS_VERSION-${_LUKS_UUID//[UID:[:space:]-]/}-"
 
-	CRYPT_NAME=$(dmsetup info -c --noheadings -S "UUID=~$_LUKS_UUID&&segments=1&&devnos_used='$MAJOR:$MINOR'" -o name)
+	CRYPT_NAME=$(dmsetup info -c --noheadings -S "UUID=~^$_LUKS_UUID&&segments=1&&devnos_used='$MAJOR:$MINOR'" -o name)
 	test -z "$CRYPT_NAME" || CRYPT_DATA_OFFSET=$(dmsetup table $CRYPT_NAME | cut -d ' ' -f 8)
 }
 


