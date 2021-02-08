From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:06 +0000 (GMT)
Subject: main - tests: check event_activation can be disabled
Message-ID: <20210208224506.2FBDC384A02A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6373f3909252e312ca2b25d42a46a712099ae7fc
Commit:        6373f3909252e312ca2b25d42a46a712099ae7fc
Parent:        b86eb913c18ca67415521b8003c04adf41a5496c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 22:27:59 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:38 2021 +0100

tests: check event_activation can be disabled

---
 test/shell/pvscan-autoactivate.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 9f7fc2ee7..153939d34 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -31,6 +31,10 @@ _clear_online_files() {
 
 aux prepare_devs 8 16
 
+# Check 'pvscan' is ignored when event_activation is 0
+pvscan --cache -aay -v --config 'global/event_activation=0' 2>&1 | tee out
+grep "Ignoring pvscan" out
+
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
 


