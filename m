From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 25 Feb 2015 22:55:28 +0000 (UTC)
Subject: master - man: lvmsystemid: empty string equals no system_id
Message-ID: <20150225225528.74232601DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71d97fd88afa0d8240569412bb1d3d256e596f6d
Commit:        71d97fd88afa0d8240569412bb1d3d256e596f6d
Parent:        efd7480de3c1be4c0e7fe2508158dce930bc2c7c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 25 16:55:56 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 25 16:55:56 2015 -0600

man: lvmsystemid: empty string equals no system_id

---
 man/lvmsystemid.7.in |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index e188c12..42eee31 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -41,7 +41,7 @@ maximum length of a system_id is 128 characters.
 .SS Limitations and warnings
 
 To benefit fully from system_id, all hosts must have system_id set, and
-VGs must have system_id set.  A VG on shared storage can be corrupted or
+VGs must have system_id set.  A VG on shared storage can be damaged or
 destroyed in the following cases which the user must be careful to avoid:
 
 .IP \[bu] 2
@@ -220,8 +220,8 @@ local {
 
 .SS vgcreate
 
-In vgcreate, a host sets its own system_id in the VG metadata.
-To override this and set another system_id:
+In vgcreate, the host running the command assigns its own system_id to the
+new VG.  To override this and set another system_id:
 
 .B vgcreate --systemid
 .I SystemID VG Devices
@@ -231,6 +231,9 @@ it may not be able to use.  Another host with a system_id matching the one
 specified may not recognize the new VG without manually rescanning
 devices.
 
+If the --systemid argument is an empty string (""), the VG is created with
+no system_id, making it accessible to other hosts (see warnings above.)
+
 .SS report/display
 
 The system_id of a VG is displayed with the "systemid" reporting option.
@@ -272,6 +275,10 @@ confirmation because the host may lose access to the VG being changed:
 .B vgchange --systemid
 .I SystemID VG
 
+The system_id can be removed from a VG by specifying an empty string ("")
+as the new system_id.  This makes the VG accessible to other hosts (see
+warnings above.)
+
 A host cannot directly change the system_id of a foreign VG.
 
 To move a VG from one host to another, vgexport and vgimport should be


