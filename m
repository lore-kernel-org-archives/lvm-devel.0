From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:48 +0000 (GMT)
Subject: main - tests: remove option chunk for mdadm raid1
Message-ID: <20230223154848.E97C63858C00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7c4fb77436d529c3a8d7a454a5acb7ff767abba
Commit:        d7c4fb77436d529c3a8d7a454a5acb7ff767abba
Parent:        6943afe9d5dc6e82444bdadf9abc54198cadfd16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 15:30:50 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:46:35 2023 +0100

tests: remove option chunk for mdadm raid1

Not sure why, but --chunk specification for mdadm raid1 is no longer
'wanted' ???
---
 test/shell/lvm-on-md.sh            | 8 ++++++--
 test/shell/pvcreate-md-fake-hdr.sh | 3 ++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index f932ca623..83478e5a1 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -53,8 +53,12 @@ for level in 1 0 ; do
 #
 # When a raid0 md array is stopped, the components will not look like
 # duplicate PVs as they do with raid1.
-
-aux mdadm_create --metadata=1.0 --level=$level --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+# mdadm does not seem to like --chunk=64 with raid1
+case "$level" in
+0) CHUNK="--chunk=64" ;;
+*) CHUNK="" ;;
+esac
+aux mdadm_create --metadata=1.0 --level=$level $CHUNK --raid-devices=2 "$dev1" "$dev2"
 mddev=$(< MD_DEV)
 
 vgcreate $vg "$mddev"
diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index f610d6fb3..856b26c24 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -36,7 +36,8 @@ vgcreate $SHARED $vg "$dev3" "$dev4"
 
 # create 2 disk MD raid1 array
 # by default using metadata format 1.0 with data@the end of device
-aux mdadm_create --metadata=1.0 --level=1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
+# passing --chunk=64 makes mdadm non functional
+aux mdadm_create --metadata=1.0 --level=1 --raid-devices=2 "$dev1" "$dev2"
 
 mddev=$(< MD_DEV)
 pvdev=$(< MD_DEV_PV)

