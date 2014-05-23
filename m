From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 May 2014 21:38:36 +0000 (UTC)
Subject: master - tests: improve command coverage
Message-ID: <20140523213836.ADEC360303@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfe18d85c148c5d3c9407fac586b28b186471615
Commit:        cfe18d85c148c5d3c9407fac586b28b186471615
Parent:        b7476e91ef4370746f85e009becb65ef891cc3d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 23 23:34:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 23 23:35:42 2014 +0200

tests: improve command coverage

---
 test/shell/listings.sh                |    1 +
 test/shell/vgextend-restoremissing.sh |   24 +++++++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 2121ecd..7069707 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -94,6 +94,7 @@ pvscan -e
 pvscan -s
 pvscan --novolumegroup
 vgscan --mknodes
+vgmknodes --refresh
 lvscan
 lvmdiskscan
 
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 143bff7..8812c8c 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -16,15 +16,37 @@ aux prepare_vg 3
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n lv1 $vg "$dev1"
 
+# vgextend require vgname
+invalid vgextend
+# --metadatacopies => use --pvmetadatacopies
+invalid vgextend --metadatacopies 3 $vg "$dev1" |& tee out
+grep -- "use --pvmetadatacopies" out
+
+# VG name should exist
+fail vgextend --restoremissing $vg-invalid "$dev1"
+
 # try to just change metadata; we expect the new version (with MISSING_PV set
 # on the reappeared volume) to be written out to the previously missing PV
 aux disable_dev "$dev1"
 lvremove $vg/mirror
+# try restore the still existing device
+fail vgextend --restore $vg "$dev1"
 aux enable_dev "$dev1"
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
 not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
-vgextend --restore $vg "$dev1" # restore the missing device
+# try restore the non-missing device
+fail vgextend --restore $vg "$dev2"
+# try restore the non-existing device
+fail vgextend --restore $vg "$dev2-invalid"
+# restore the missing device
+vgextend --restore $vg "$dev1"
+
+vgreduce  $vg "$dev3"
+vgchange --metadatacopies 1 $vg
+# 'n' failing to change volume group
+fail vgextend --metadataignore y --pvmetadatacopies 2 $vg "$dev3"
+vgextend --yes --metadataignore y --pvmetadatacopies 2 $vg "$dev3"
 vgck $vg
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 


