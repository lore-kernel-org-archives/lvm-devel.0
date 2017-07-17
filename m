From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:41:29 -0400
Subject: master - test: repeat rediscovery few times
Message-ID: <201707171141.v6HBfTjb022695@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c32883cec807a8759dfa98bf258ed6e10ca997f
Commit:        3c32883cec807a8759dfa98bf258ed6e10ca997f
Parent:        f293d469463ad26cbd5e1aefce6e939afceb36ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 18:29:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 13:38:31 2017 +0200

test: repeat rediscovery few times

Avoid using 'aux' shell when setting dmsetup cookie.
Do not user '--force' when using external cookie.
---
 test/shell/lvmetad-ambiguous.sh |   44 +++++++++++++++++++++++++++++++++++---
 1 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvmetad-ambiguous.sh b/test/shell/lvmetad-ambiguous.sh
index 71677c8..4b69c13 100644
--- a/test/shell/lvmetad-ambiguous.sh
+++ b/test/shell/lvmetad-ambiguous.sh
@@ -19,12 +19,32 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_pvs 2
 
 # flip the devices around
-aux init_udev_transaction
-dmsetup remove -f "$dev1"
-dmsetup remove -f "$dev2"
+init_udev_transaction
+dmsetup remove "$dev1"
+dmsetup remove "$dev2"
+dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv2 ${PREFIX}pv2.table
+dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv1 ${PREFIX}pv1.table
+finish_udev_transaction
+dmsetup info -c
+
+# re-scan them
+pvscan --cache "$dev1" || true
+pvscan --cache "$dev2" || true
+
+# expect both to be there
+pvs -a -o name | tee out
+grep "$dev1" out
+grep "$dev2" out
+
+aux lvmetad_dump
+
+# flip the devices 2nd. time around
+init_udev_transaction
+dmsetup remove "$dev1"
+dmsetup remove "$dev2"
 dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv2 ${PREFIX}pv2.table
 dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv1 ${PREFIX}pv1.table
-aux finish_udev_transaction
+finish_udev_transaction
 
 # re-scan them
 pvscan --cache "$dev1" || true
@@ -35,3 +55,19 @@ pvs -a -o name | tee out
 grep "$dev1" out
 grep "$dev2" out
 
+aux lvmetad_dump
+
+# flip the devices 2nd. time around
+dmsetup remove -f "$dev1"
+dmsetup remove -f "$dev2"
+dmsetup create -u TEST-${PREFIX}pv1 ${PREFIX}pv2 ${PREFIX}pv2.table
+dmsetup create -u TEST-${PREFIX}pv2 ${PREFIX}pv1 ${PREFIX}pv1.table
+
+# re-scan them
+pvscan --cache "$dev1" || true
+pvscan --cache "$dev2" || true
+
+# expect both to be there
+pvs -a -o name | tee out
+grep "$dev1" out
+grep "$dev2" out


