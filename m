From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:39:14 -0400
Subject: master - tests: updates test for raid scanning
Message-ID: <201806081239.w58CdEGZ006133@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59dc9b445d6dba0ae119a2f517f4f665c6c522a9
Commit:        59dc9b445d6dba0ae119a2f517f4f665c6c522a9
Parent:        f20e828ec2c6ef6fbd6a271ecbf904a8e7943958
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 18:45:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

tests: updates test for raid scanning

---
 test/shell/pvcreate-md-fake-hdr.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-md-fake-hdr.sh b/test/shell/pvcreate-md-fake-hdr.sh
index b89fe43..13d810c 100644
--- a/test/shell/pvcreate-md-fake-hdr.sh
+++ b/test/shell/pvcreate-md-fake-hdr.sh
@@ -25,6 +25,12 @@ aux extend_filter_LVMTEST "a|/dev/md|"
 
 aux prepare_devs 4
 
+pvcreate "$dev2"
+aux prepare_md_dev 0 64 2 "$dev1" "$dev2"
+# Incorrectly shows  $dev2 as PV for 'raid0'
+pvs -vvvv
+
+
 vgcreate $SHARED $vg "$dev3" "$dev4"
 
 # create 2 disk MD raid1 array


