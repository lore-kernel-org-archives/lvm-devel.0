From: David Teigland <teigland@sourceware.org>
Date: Thu, 5 Sep 2019 16:28:23 -0400
Subject: master - tests: metadata-bad-text.sh with lvmlockd
Message-ID: <201909052028.x85KSNM9019456@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acb8050a30fb61ce5188d5c6daa8177942da0538
Commit:        acb8050a30fb61ce5188d5c6daa8177942da0538
Parent:        fcbffbdbc0a29287c65bfc378eb8aa99fd6490c1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 5 15:27:52 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 5 15:27:52 2019 -0500

tests: metadata-bad-text.sh with lvmlockd

skip part of test that doesn't apply
---
 test/shell/metadata-bad-text.sh |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/metadata-bad-text.sh b/test/shell/metadata-bad-text.sh
index 2937a66..421706a 100644
--- a/test/shell/metadata-bad-text.sh
+++ b/test/shell/metadata-bad-text.sh
@@ -250,6 +250,11 @@ vgremove -ff $vg
 # Test pvscan activation with bad PVs
 #
 
+# autoactivation not done on shared VGs
+if test -n "$LVM_TEST_LVMLOCKD"; then
+exit 0
+fi
+
 dd if=/dev/zero of="$dev1" || true
 dd if=/dev/zero of="$dev2" || true
 dd if=/dev/zero of="$dev3" || true


