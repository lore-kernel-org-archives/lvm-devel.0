From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  5 Mar 2015 18:12:40 +0000 (UTC)
Subject: master - man: add info to lvmsystemid
Message-ID: <20150305181240.D62CE610DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b48ff3b94e7cd771bbaf42f38b546054d02bc0f2
Commit:        b48ff3b94e7cd771bbaf42f38b546054d02bc0f2
Parent:        5e25bca1a98f2376b94904a2e220a3e2f68923ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 5 12:12:42 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 5 12:12:42 2015 -0600

man: add info to lvmsystemid

about losing access to a VG if lvm is downgraded
to an earlier version.
---
 man/lvmsystemid.7.in |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 0881b1e..76b0e83 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -42,13 +42,7 @@ maximum length of a system_id is 128 characters.
 
 To benefit fully from system_id, all hosts must have system_id set, and
 VGs must have system_id set.  A VG on shared storage can be damaged or
-destroyed in the following cases which the user must be careful to avoid:
-
-.IP \[bu] 2
-A host using an old version of lvm without the system_id feature will not
-recognize the system_id of other hosts' VGs.  VGs with a new system_id
-are nominally protected from old versions of lvm by appearing to be
-read-only to the old versions.
+destroyed in some cases which the user must be careful to avoid.
 
 .IP \[bu] 2
 A VG without a system_id can be used without restriction from any host,
@@ -73,6 +67,19 @@ operations and corrupting the PVs.  See the
 .B orphans
 section for more information.
 
+.IP \[bu] 2
+A host using an old version of lvm without the system_id feature will not
+recognize a new system_id in VGs from other hosts.  Even though the old
+version of lvm is not blocked from reading a VG with a system_id, it is
+blocked from writing to the VG (or its LVs).  The new system_id changes
+the write mode of a VG, making it appear read-only to previous lvm
+versions.
+
+This also means that if a host downgrades its version of lvm, it would
+lose access to any VGs it had created with a system_id.  To avoid this,
+the system_id should be removed from VGs before downgrading to an lvm
+version without the system_id feature.
+
 .P
 
 .SS Types of VG access


