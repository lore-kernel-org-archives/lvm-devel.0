From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 15 Oct 2012 20:42:41 +0000 (UTC)
Subject: master - RAID: Add "raid10" to lvcreate man page.
Message-ID: <20121015204241.61426A0C4B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67379a3ffdafa69a2830a1155fe9b4689bbf71cb
Commit:        67379a3ffdafa69a2830a1155fe9b4689bbf71cb
Parent:        7519d881ef07c4a515716099a4bf9566b7f71b1a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 15 15:41:14 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 15 15:41:14 2012 -0500

RAID:  Add "raid10" to lvcreate man page.

In addition to reference to raid10 under the '--type' argument, an
example creating a RAID10 LV has been added.
---
 man/lvcreate.8.in |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index fb54cc6..f374950 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -298,7 +298,7 @@ commandline switch alias that will enable their use
 However, this argument must be used when no existing
 commandline switch alias is available for the desired type,
 as is the case with
-.IR error ", " zero ", " raid1 ", " raid4 ", " raid5 " or " raid6 .
+.IR error ", " zero ", " raid1 ", " raid10 ", " raid4 ", " raid5 " or " raid6 .
 .TP
 .BR \-V ", " \-\-virtualsize " " \fIVirtualSize [ \fIbBsSkKmMgGtTpPeE ]
 Create a sparse device of the given size (in MB by default) using a snapshot
@@ -363,6 +363,14 @@ a parity drive for a total of 4 devices) and a stripesize of 64KiB:
 .sp
 .B lvcreate \-\-type raid5 \-L 5G \-i 3 \-I 64 \-n my_lv vg00
 
+Creates a 5GiB RAID10 logical volume "vg00/my_lv", with 2 stripes on
+2 2-way mirrors.  Note that the '-i' and '-m' arguments behave differently.
+The '-i' specifies the number of stripes.  The '-m' specifies the number of
+.B additional 
+copies.
+.sp
+.B lvcreate \-\-type raid10 \-L 5G \-i 2 \-m 1 \-n my_lv vg00
+
 Creates 100MiB pool logical volume for thin provisioning
 build with 2 stripes 64KiB and chunk size 128KiB together with
 1TiB thin provisioned logical volume "vg00/thin_lv":


