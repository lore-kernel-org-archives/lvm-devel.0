From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:03:53 +0000 (GMT)
Subject: stable-2.02 - fsadm: avoid access to unbound variable
Message-ID: <20210223140353.DB9D3388703F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c94657cc2e678b0937fa770f4280507d1118ef4c
Commit:        c94657cc2e678b0937fa770f4280507d1118ef4c
Parent:        87e0b1a36faa54c6fc27837cac3be01a1553eaf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 14:14:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 15:01:53 2021 +0100

fsadm: avoid access to unbound variable

---
 scripts/fsadm.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 2cb1fc75b..4f59cee13 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -163,7 +163,7 @@ cleanup() {
 		_FSADM_EXTOFF=$EXTOFF
 		export _FSADM_YES _FSADM_EXTOFF
 		unset FSADM_RUNNING
-		test -n "$LVM_BINARY" && PATH=$_SAVEPATH
+		test -n "${LVM_BINARY-}" && PATH=$_SAVEPATH
 		dry exec "$LVM" lvresize $VERB $FORCE -r -L"${NEWSIZE_ORIG}b" "$VOLUME_ORIG"
 	fi
 


