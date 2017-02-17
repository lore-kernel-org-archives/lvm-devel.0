From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Feb 2017 21:34:17 +0000 (UTC)
Subject: master - man pvmove: move details to notes
Message-ID: <20170217213417.4B3F660E2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87fe9328d30660e2eecd990bfce893ae65817f44
Commit:        87fe9328d30660e2eecd990bfce893ae65817f44
Parent:        6064b0359a7f3fbc07e56dd7094732ea184c199e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 17 15:28:00 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 17 15:28:00 2017 -0600

man pvmove: move details to notes

---
 man/pvmove.8.des |   45 ---------------------------------------------
 man/pvmove.8.end |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 45 deletions(-)

diff --git a/man/pvmove.8.des b/man/pvmove.8.des
index 5286ef4..c003c5e 100644
--- a/man/pvmove.8.des
+++ b/man/pvmove.8.des
@@ -14,48 +14,3 @@ More than one pvmove can run concurrently if they are moving data from
 different source PVs, but additional pvmoves will ignore any LVs already
 in the process of being changed, so some data might not get moved.
 
-pvmove works as follows:
-
-1. A temporary 'pvmove' LV is created to store details of all the data
-movements required.
-
-2. Every LV in the VG is searched for contiguous data that need moving
-according to the command line arguments.
-For each piece of data found, a new segment is added to the end of the
-pvmove LV.
-This segment takes the form of a temporary mirror to copy the data 
-from the original location to a newly allocated location.
-The original LV is updated to use the new temporary mirror segment
-in the pvmove LV instead of accessing the data directly.
-
-3. The VG metadata is updated on disk.
-
-4. The first segment of the pvmove LV is activated and starts to mirror
-the first part of the data.  Only one segment is mirrored at once as this
-is usually more efficient.
-
-5. A daemon repeatedly checks progress at the specified time interval.
-When it detects that the first temporary mirror is in sync, it breaks that
-mirror so that only the new location for that data gets used and writes a
-checkpoint into the VG metadata on disk.  Then it activates the mirror for
-the next segment of the pvmove LV.
-
-6. When there are no more segments left to be mirrored, the temporary LV
-is removed and the VG metadata is updated so that the LVs reflect the new
-data locations.
-
-Note that this new process cannot support the original LVM1
-type of on-disk metadata.  Metadata can be converted using
-\fBvgconvert\fP(8).
-
-If the \fB\-\-atomic\fP option is used, a slightly different approach is
-used for the move.  Again, a temporary 'pvmove' LV is created to store the
-details of all the data movements required.  This temporary LV contains
-all the segments of the various LVs that need to be moved.  However, in
-this case, an identical LV is allocated that contains the same number of
-segments and a mirror is created to copy the contents from the first
-temporary LV to the second.  After a complete copy is made, the temporary
-LVs are removed, leaving behind the segments on the destination PV.  If an
-abort is issued during the move, all LVs being moved will remain on the
-source PV.
-
diff --git a/man/pvmove.8.end b/man/pvmove.8.end
index 9dd3adc..906606d 100644
--- a/man/pvmove.8.end
+++ b/man/pvmove.8.end
@@ -1,3 +1,50 @@
+.SH NOTES
+
+pvmove works as follows:
+
+1. A temporary 'pvmove' LV is created to store details of all the data
+movements required.
+
+2. Every LV in the VG is searched for contiguous data that need moving
+according to the command line arguments.
+For each piece of data found, a new segment is added to the end of the
+pvmove LV.
+This segment takes the form of a temporary mirror to copy the data
+from the original location to a newly allocated location.
+The original LV is updated to use the new temporary mirror segment
+in the pvmove LV instead of accessing the data directly.
+
+3. The VG metadata is updated on disk.
+
+4. The first segment of the pvmove LV is activated and starts to mirror
+the first part of the data.  Only one segment is mirrored at once as this
+is usually more efficient.
+
+5. A daemon repeatedly checks progress at the specified time interval.
+When it detects that the first temporary mirror is in sync, it breaks that
+mirror so that only the new location for that data gets used and writes a
+checkpoint into the VG metadata on disk.  Then it activates the mirror for
+the next segment of the pvmove LV.
+
+6. When there are no more segments left to be mirrored, the temporary LV
+is removed and the VG metadata is updated so that the LVs reflect the new
+data locations.
+
+Note that this new process cannot support the original LVM1
+type of on-disk metadata.  Metadata can be converted using
+\fBvgconvert\fP(8).
+
+If the \fB\-\-atomic\fP option is used, a slightly different approach is
+used for the move.  Again, a temporary 'pvmove' LV is created to store the
+details of all the data movements required.  This temporary LV contains
+all the segments of the various LVs that need to be moved.  However, in
+this case, an identical LV is allocated that contains the same number of
+segments and a mirror is created to copy the contents from the first
+temporary LV to the second.  After a complete copy is made, the temporary
+LVs are removed, leaving behind the segments on the destination PV.  If an
+abort is issued during the move, all LVs being moved will remain on the
+source PV.
+
 .SH EXAMPLES
 
 Move all physical extents that are used by simple LVs on the specified PV to


