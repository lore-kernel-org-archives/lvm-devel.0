From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  7 Aug 2015 21:35:45 +0000 (UTC)
Subject: master - man: mention system ID in vgexport and vgimport
Message-ID: <20150807213545.6456C60139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b59cdf089217e1b86b2106bdccb990bda92690e5
Commit:        b59cdf089217e1b86b2106bdccb990bda92690e5
Parent:        993fe07a3c9cd756d854d36d576cba5620bf3e36
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 7 16:35:07 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 7 16:35:07 2015 -0500

man: mention system ID in vgexport and vgimport

---
 man/vgexport.8.in |    5 ++++-
 man/vgimport.8.in |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/man/vgexport.8.in b/man/vgexport.8.in
index 94a3e32..08c1d78 100644
--- a/man/vgexport.8.in
+++ b/man/vgexport.8.in
@@ -20,6 +20,8 @@ You can then move all the Physical Volumes in that Volume Group to
 a different system for later
 .BR vgimport (8).
 Most LVM2 tools ignore exported Volume Groups.
+vgexport clears the VG system ID, and vgimport sets the VG system ID
+to match the host running vgimport (if the host has a system ID).
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -29,4 +31,5 @@ Export all inactive Volume Groups.
 .BR lvm (8),
 .BR pvscan (8),
 .BR vgimport (8),
-.BR vgscan (8)
+.BR vgscan (8),
+.BR lvmsystemid (7)
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
index 3a8a230..cd34049 100644
--- a/man/vgimport.8.in
+++ b/man/vgimport.8.in
@@ -16,6 +16,8 @@ exported using
 .BR vgexport (8)
 known to the system again, perhaps after moving its Physical Volumes
 from a different machine.
+vgexport clears the VG system ID, and vgimport sets the VG system ID
+to match the host running vgimport (if the host has a system ID).
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
@@ -30,4 +32,5 @@ failed and they cannot be restored.
 .BR lvm (8),
 .BR pvscan (8),
 .BR vgexport (8),
-.BR vgscan (8)
+.BR vgscan (8),
+.BR lvmsystemid (7)


