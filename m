From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:28:07 -0400
Subject: master - tests: secure rm call
Message-ID: <201707101228.v6ACS7sh021736@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e47ab9b8c4526d1663da4aa3122b013237aaf9f
Commit:        2e47ab9b8c4526d1663da4aa3122b013237aaf9f
Parent:        4ed3f1bee3fca0b27ace8bfe593aa6aee15a3a19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 11:50:33 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: secure rm call

Use "${var:?}" to ensure this never expands to / .
(Should never happen as 'dir' was supposed to exist from preceding
test.)
---
 test/shell/profiles-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 81ac90b..9c9fadf 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -62,7 +62,7 @@ vgremove -ff $vg
 
 if test -d "$DM_DEV_DIR/$vg" ; then
 	should not echo "Udev has left \"$DM_DEV_DIR/$vg\"!"
-	rm -rf "$DM_DEV_DIR/$vg"
+	rm -rf "${DM_DEV_DIR:?/dev}/$vg"
 fi
 
 # The profile must be also applied if using the profile


