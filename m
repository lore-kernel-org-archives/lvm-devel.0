From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 6 Mar 2017 13:33:54 -0500
Subject: master - man lvs: describe new 'R' volume health character
Message-ID: <201703061833.v26IXs4x003992@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=872932a0fb31af4bb52b575157bc7f93025bfd59
Commit:        872932a0fb31af4bb52b575157bc7f93025bfd59
Parent:        0b019c5406c27edfd00b502a95cb57e198c949a8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Mar 6 19:33:10 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Mar 6 19:33:10 2017 +0100

man lvs: describe new 'R' volume health character

---
 man/lvs.8.end |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/man/lvs.8.end b/man/lvs.8.end
index d71f7c1..ff92148 100644
--- a/man/lvs.8.end
+++ b/man/lvs.8.end
@@ -56,6 +56,7 @@ Inconsistencies are detected by initiating a "check" on a RAID logical volume.
 (The scrubbing operations, "check" and "repair", can be performed on a RAID
 logical volume via the 'lvchange' command.)  (w)ritemostly signifies the
 devices in a RAID 1 logical volume that have been marked write-mostly.
+(R)emove after reshape signifies freed striped raid images to be removed.
 .IP
 Related to Thin pool Logical Volumes: (F)ailed, out of (D)ata space,
 (M)etadata read only.


