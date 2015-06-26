From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 26 Jun 2015 20:17:45 +0000 (UTC)
Subject: master - tests: deactivate before remove
Message-ID: <20150626201745.D082A600C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03c4fee5a7afeeae0b3c215779d24b5faaa1ac26
Commit:        03c4fee5a7afeeae0b3c215779d24b5faaa1ac26
Parent:        a62cd64db6c65637f2f2125222962696a7c7c5ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 26 22:00:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 26 22:11:46 2015 +0200

tests: deactivate before remove

Testing if this avoids udev race with removal of snapshot on some
test machines.
See: https://bugzilla.redhat.com/show_bug.cgi?id=1217819
---
 test/shell/lvconvert-repair-snapshot.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 1bb4138..73f2f88 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -28,4 +28,5 @@ aux enable_dev "$dev2" "$dev4"
 lvs -a -o +devices $vg
 check mirror $vg 4way "$dev5"
 
+vgchange -an $vg
 vgremove -ff $vg


