From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:43:45 +0000 (UTC)
Subject: master - tests: check that pvscan cannot activate exported VG
Message-ID: <20161103164345.D503F60EB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=221d8ff2a420a4104826907de9d71100dc208834
Commit:        221d8ff2a420a4104826907de9d71100dc208834
Parent:        28b210f4fa10ef5e9baf4e28a891460eb65eb602
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 3 11:43:08 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 3 11:43:37 2016 -0500

tests: check that pvscan cannot activate exported VG

---
 test/shell/lvmetad-pvscan-cache.sh |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 501eec5..8b1e8c2 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -24,6 +24,28 @@ pvscan --cache
 
 vgs | grep $vg1
 
+# Check that an LV cannot be activated by lvchange while VG is exported
+lvcreate -n $lv1 -l 4 -a n $vg1
+check lv_exists $vg1
+vgexport $vg1
+fail lvs $vg1
+fail lvchange -ay $vg1/$lv1
+vgimport $vg1
+check lv_exists $vg1
+check lv_field $vg/$lv1 lv_active ""
+
+# Check that an LV cannot be activated by pvscan while VG is exported
+vgexport $vg1
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
+vgimport $vg1
+check lv_exists $vg1
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay "$dev1"
+pvscan --cache -aay "$dev2"
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1/$lv1
+
 # When MDA is ignored on PV, do not read any VG
 # metadata from such PV as it may contain old
 # metadata which hasn't been updated for some


