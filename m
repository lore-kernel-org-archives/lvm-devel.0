From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  7 Jul 2016 22:21:15 +0000 (UTC)
Subject: master - man: more lvcreate size rewording
Message-ID: <20160707222115.D7DCB60C84@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6233bcf52d98d9d0a3c87b22cb7700521b5358a2
Commit:        6233bcf52d98d9d0a3c87b22cb7700521b5358a2
Parent:        589b752eeb6b442f2987b1cd1736f8f461c9aa95
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 7 17:21:05 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 7 17:21:05 2016 -0500

man: more lvcreate size rewording

---
 man/lvcreate.8.in |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index b7ad7bb..1bc2a91 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -336,12 +336,13 @@ metadata.  An alternate syntax allows the size to be determined indirectly
 as a percentage of the size of a related VG, LV, or set of PVs.  The
 suffix \fB%VG\fP denotes the total size of the VG, the suffix \fB%FREE\fP
 the remaining free space in the VG, and the suffix \fB%PVS\fP the free
-space in the specified Physical Volumes.  For a snapshot, the upper bound
+space in the specified Physical Volumes.  For a snapshot, the size
 can be expressed as a percentage of the total size of the Origin Logical
 Volume with the suffix \fB%ORIGIN\fP (\fB100%ORIGIN\fP provides space for
-the whole origin).  When expressed as a percentage, the number is treated
-as an approximate upper limit, and the final size of the LV is not known
-until the command is complete.
+the whole origin).
+When expressed as a percentage, the size defines an upper limit for the
+number of logical extents in the new LV. The precise number of logical
+extents in the new LV is not determined until the command has completed.
 .
 .HP
 .BR \-j | \-\-major


