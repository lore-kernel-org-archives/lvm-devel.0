From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 12 Jan 2015 14:21:29 +0000 (UTC)
Subject: master - tests: pvscan --cache DevicePath does not fail if the device is just filtered
Message-ID: <20150112142129.91707609E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8804023825e9eb00df653a7c5116097d1ce49087
Commit:        8804023825e9eb00df653a7c5116097d1ce49087
Parent:        99d895014d971395fe7a739838952e7405eb4dda
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 12 15:16:57 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 12 15:16:57 2015 +0100

tests: pvscan --cache DevicePath does not fail if the device is just filtered

It's not an error if the device is filtered out and hence cleared from
lvmetad cache - "pvscan --cache DevPath" has now the same behaviour in
this case as "pvscan --cache major:minor" (which is more consistent).

Before, the tests expected failure return code for "pvscan --cache DevicePath"
if the device was filtered (which is a different situation if the device
is missing in the system completely!).
---
 test/shell/lvmetad-pvscan-filter.sh |    4 +++-
 test/shell/lvmetad-pvscan-md.sh     |    4 ++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-filter.sh b/test/shell/lvmetad-pvscan-filter.sh
index a3af1b2..05666df 100644
--- a/test/shell/lvmetad-pvscan-filter.sh
+++ b/test/shell/lvmetad-pvscan-filter.sh
@@ -18,8 +18,10 @@ aux prepare_pvs 2
 maj=$(($(stat -L --printf=0x%t "$dev2")))
 min=$(($(stat -L --printf=0x%T "$dev2")))
 
+# Filter out device, pvscan should trigger
+# clearing of the device from lvmetad cache.
 aux hide_dev "$dev2"
-not pvscan --cache "$dev2" 2>&1 | grep "not found"
+pvscan --cache "$dev2" 2>&1 | grep "not found"
 # pvscan with --major/--minor does not fail: lvmetad needs to
 # be notified about device removal on REMOVE uevent, hence
 # this should not fail so udev does not grab a "failed" state
diff --git a/test/shell/lvmetad-pvscan-md.sh b/test/shell/lvmetad-pvscan-md.sh
index 449369d..653d18a 100644
--- a/test/shell/lvmetad-pvscan-md.sh
+++ b/test/shell/lvmetad-pvscan-md.sh
@@ -69,8 +69,8 @@ pvcreate $lvmdev
 pvscan --cache "$lvmdev"
 
 # ensure that lvmetad can only see the toplevel MD device
-not pvscan --cache "$dev1" 2>&1 | grep "not found"
-not pvscan --cache "$dev2" 2>&1 | grep "not found"
+pvscan --cache "$dev1" 2>&1 | grep "not found"
+pvscan --cache "$dev2" 2>&1 | grep "not found"
 
 pvs | grep $lvmdev
 pvs | not grep "$dev1"


