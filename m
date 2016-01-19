From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 14:28:54 +0000 (UTC)
Subject: master - man: mention GPT id for LVM in pvcreate man page
Message-ID: <20160119142854.5EEF260DC1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f6a1e6bbac41bb5d0e18876c23a7442c8c0d263
Commit:        7f6a1e6bbac41bb5d0e18876c23a7442c8c0d263
Parent:        2a4ef78c4a7212b5f1416a0532fa83bbbe74561a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 15:28:44 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 15:28:44 2016 +0100

man: mention GPT id for LVM in pvcreate man page

---
 man/pvcreate.8.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/man/pvcreate.8.in b/man/pvcreate.8.in
index 9011585..a50aaa7 100644
--- a/man/pvcreate.8.in
+++ b/man/pvcreate.8.in
@@ -48,7 +48,8 @@ can be a disk partition, whole disk, meta device, or loopback file.
 For DOS disk partitions, the partition id should be set to 0x8e using
 .BR fdisk (8),
 .BR cfdisk (8),
-or a equivalent.  For
+or a equivalent. For GUID Partition Table (GPT), the id is
+E6D6D379-F507-44C2-A23C-238F2A3DF928. For
 .B whole disk devices only
 the partition table must be erased, which will effectively destroy all
 data on that disk.  This can be done by zeroing the first sector with:


