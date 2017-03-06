From: David Teigland <teigland@sourceware.org>
Date: Mon, 6 Mar 2017 12:28:50 -0500
Subject: master - man lvextend: mention segment type
Message-ID: <201703061728.v26HSosK021270@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef97360866d8a9221eb8d9b2d0e2f7e366bbd8ef
Commit:        ef97360866d8a9221eb8d9b2d0e2f7e366bbd8ef
Parent:        17838e6439f7cabfa4609dbfb48197d5a33138f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 6 11:27:56 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 6 11:27:56 2017 -0600

man lvextend: mention segment type

---
 man/lvextend.8.des |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/man/lvextend.8.des b/man/lvextend.8.des
index 346bd23..4c0575d 100644
--- a/man/lvextend.8.des
+++ b/man/lvextend.8.des
@@ -1,7 +1,10 @@
 lvextend extends the size of an LV. This requires allocating logical
-extents from the VG's free physical extents. A copy\-on\-write snapshot LV
-can also be extended to provide more space to hold COW blocks. Use
-\fBlvconvert\fP(8) to change the number of data images in a RAID or
+extents from the VG's free physical extents. If the extension adds a new
+LV segment, the new segment will use the existing segment type of the LV.
+
+Extending a copy\-on\-write snapshot LV adds space for COW blocks.
+
+Use \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
 
 In the usage section below, \fB--size\fP \fISize\fP can be replaced


