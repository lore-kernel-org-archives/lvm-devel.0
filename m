From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:11 +0000 (GMT)
Subject: main - fsadm: avoid access to unbound variable
Message-ID: <20210223140411.D750E389682C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=646e3280ddf5e73040e12122b8a7a2fad52668a0
Commit:        646e3280ddf5e73040e12122b8a7a2fad52668a0
Parent:        9e836c77a0663649468af613436c210e3ba324b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 14:14:16 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:47 2021 +0100

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
 


