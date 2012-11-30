From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 30 Nov 2012 23:01:36 +0000 (UTC)
Subject: master - man page (lvcreate): Better explain stripes option for RAID 4/5/6.
Message-ID: <20121130230136.98DD5A0E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=83978cdec8aa6f6b6af2cb8937d64cc16b88cf18
Commit:        83978cdec8aa6f6b6af2cb8937d64cc16b88cf18
Parent:        ed9751d9fa6638e0cae5aa38727f971eeac6516c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Nov 30 16:47:02 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Nov 30 16:47:02 2012 -0600

man page (lvcreate):  Better explain stripes option for RAID 4/5/6.

Do a better job explaining the '--stripes/-i' option to lvcreate
when it comes to RAID 4/5/6.  The extra devices needed for parity
are implicitly added to the argument given.  So a 5-device RAID6
logical volume is created with '-i 3' - indicating 3 stripes plus
the implicit 2 devices needed for RAID6.
---
 man/lvcreate.8.in |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 705ebae..da4c1fe 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -150,7 +150,11 @@ Default is \fIpassdown\fP.
 .BR \-i ", " \-\-stripes " " \fIStripes
 Gives the number of stripes.
 This is equal to the number of physical volumes to scatter
-the logical volume.
+the logical volume.  When creating a RAID 4/5/6 logical volume,
+the extra devices which are necessary for parity are
+internally accounted for.  Specifying '\-i 3' would use 3 devices
+for striped logical volumes, 4 devices for RAID 4/5, and 5 devices
+for RAID 6.
 .TP
 .BR \-I ", " \-\-stripesize " " \fIStripeSize
 Gives the number of kilobytes for the granularity of the stripes.


