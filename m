From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 21 Jan 2017 21:56:21 +0000 (UTC)
Subject: master - tests: umount when above 95
Message-ID: <20170121215621.1569A60D47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d48317d3aa2283e606c9a200b68bd3eac67f0a4
Commit:        2d48317d3aa2283e606c9a200b68bd3eac67f0a4
Parent:        e2fa90bf38461a5de63cd11ffcc01fb984c8193b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 21 22:53:57 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jan 21 22:53:57 2017 +0100

tests: umount when above 95

Add code to check if resulting data or metadata remained over 95%
and in such case invoke umount.
---
 test/shell/thin-autoumount-dmeventd.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
index eacad0a..b2b20a5 100644
--- a/test/shell/thin-autoumount-dmeventd.sh
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -54,6 +54,12 @@ echo "Metadata: \$DMEVENTD_THIN_POOL_METADATA"
 $TESTDIR/lib/lvextend --use-policies \$1 || {
 	umount "$mntdir"  || true
 	umount "$mntusedir" || true
+	return 1
+}
+test \$($TESTDIR/lib/lvs -o selected -S "data_percent>95||metadata_percent>95" --noheadings \$1) -eq 0 || {
+	umount "$mntdir"  || true
+	umount "$mntusedir" || true
+	return 1
 }
 EOF
 chmod +x testcmd.sh


