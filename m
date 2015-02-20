From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 22:26:43 +0000 (UTC)
Subject: master - man lvm: document --foreign option
Message-ID: <20150220222643.4E99E60E93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfd1b8eae2e2cf30768603d11756f6ec9316958a
Commit:        cfd1b8eae2e2cf30768603d11756f6ec9316958a
Parent:        37a47c0eec68fe3b7abf760be87e619aa51bc544
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 16:26:04 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 16:26:04 2015 -0600

man lvm: document --foreign option

---
 man/lvm.8.in |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 7bc4c6b..766b8aa 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -243,6 +243,12 @@ will be made to communicate with the device-mapper kernel driver, so
 this option is unable to report whether or not Logical Volumes are 
 actually in use.
 .TP
+.B \-\-foreign
+Cause the command to access foreign VGs, that would otherwise be skipped.
+It can be used to report or display a VG that is owned by another host.
+This option can cause a command to perform poorly because lvmetad caching
+is not used and metadata is read from disks.
+.TP
 .B \-\-addtag \fITag
 Add the tag \fITag\fP to a PV, VG or LV.
 Supply this argument multiple times to add more than one tag at once.


