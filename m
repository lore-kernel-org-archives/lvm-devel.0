From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:46:10 +0000 (UTC)
Subject: master - tests: add more pvdisplay tests
Message-ID: <20140330214610.8AB8D602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f9150c241f80b2fd69d2e416340707759e79ac8
Commit:        8f9150c241f80b2fd69d2e416340707759e79ac8
Parent:        1216aa7826428dfa5f83af4bd29c7741de7a1a23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 23:15:16 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:45:00 2014 +0200

tests: add more pvdisplay tests

---
 test/shell/listings.sh |   26 +++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 0d69957..414b146 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -25,6 +25,7 @@ pvcreate --metadatacopies 0 "$dev5"
 
 #COMM bz195276 -- pvs doesn't show PVs until a VG is created
 test $(pvs --noheadings $(cat DEVICES) | wc -l) -eq 5
+pvdisplay
 
 #COMM pvs with segment attributes works even for orphans
 test $(pvs --noheadings -o seg_all,pv_all,lv_all,vg_all $(cat DEVICES) | wc -l) -eq 5
@@ -122,13 +123,36 @@ invalid lvdisplay --separator : $vg
 invalid lvdisplay --sort size $vg
 invalid lvdisplay --unbuffered $vg
 
-
 invalid vgdisplay -C -A
 invalid vgdisplay -C -c
 invalid vgdisplay -C -s
 invalid vgdisplay -c -s
 invalid vgdisplay -A $vg1
 
+invalid pvdisplay -C -A
+invalid pvdisplay -C -c
+invalid pvdisplay -C -m
+invalid pvdisplay -C -s
+invalid pvdisplay -c -m
+invalid pvdisplay -c -s
+invalid pvdisplay --alianed
+invalid pvdisplay --all
+invalid pvdisplay --noheadings
+invalid pvdisplay --options
+invalid pvdisplay --separator :
+invalid pvdisplay --sort size
+invalid pvdisplay --unbuffered
+invalid pvdisplay -A $vg1
+
+# Check exported VG listing
+vgchange -an $vg
+vgexport -a
+pvdisplay --noheadings -C -o attr,name | tee out
+not grep -v "ax-" out
+vgimport -a
+pvdisplay --noheadings -C -o attr,name | tee out
+grep -v "ax-" out
+
 vgremove -ff $vg
 
 #test vgdisplay -A to select only active VGs


