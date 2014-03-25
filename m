From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:51 +0000 (UTC)
Subject: master - tests: relocate vgimport test
Message-ID: <20140325102351.8FF4B60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db04d3e6d29dde331a88eec2cec5249ee7c211f0
Commit:        db04d3e6d29dde331a88eec2cec5249ee7c211f0
Parent:        13258d6e96a43fa88b41e21befd31836f21b59dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 09:58:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:59 2014 +0100

tests: relocate vgimport test

It seem like a better-fit here.
---
 test/shell/covercmd.sh      |    7 -------
 test/shell/vgimportclone.sh |    6 ++++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index ffa48f0..f1bdca9 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -64,13 +64,6 @@ for i in h b s k m g t p e H B S K M G T P E; do
 done
 fi
 
-
-# test vgexport vgimport tools
-vgchange -an $vg
-vgexport $vg
-vgimport $vg
-vgchange -ay $vg
-
 # "-persistent y --major 254 --minor 20"
 # "-persistent n"
 # test various lvm utils
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index f2977c9..923638e 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -16,6 +16,12 @@ aux prepare_devs 2
 vgcreate --metadatasize 128k $vg1 "$dev1"
 lvcreate -l100%FREE -n $lv1 $vg1
 
+# Test plain vgexport vgimport tools
+vgchange -an $vg1
+vgexport $vg1
+vgimport $vg1
+vgchange -ay $vg1
+
 # Clone the LUN
 dd if="$dev1" of="$dev2" bs=256K count=1
 aux notify_lvmetad "$dev2"


