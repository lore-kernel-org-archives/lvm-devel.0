From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 18:22:41 +0000 (UTC)
Subject: master - man lvmsystemid: expanded limitations and warnings
Message-ID: <20150220182241.C26B060F2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e0946dca69d631106c99edcef1221af78819e2c0
Commit:        e0946dca69d631106c99edcef1221af78819e2c0
Parent:        6bc35a351ace5ff5da07280fda288027cf614a13
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 12:21:23 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 12:21:23 2015 -0600

man lvmsystemid: expanded limitations and warnings

---
 man/lvmsystemid.7.in |   55 ++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 44 insertions(+), 11 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 15b69a2..9e3e6f8 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -23,23 +23,56 @@ set to a custom value or it can be assigned automatically by lvm using a
 unique identifier already available on the host, e.g. machine-id or uname.
 
 In vgcreate, the local system_id is saved in the new VG metadata.  The
-local host owns the new VG, and other hosts will ignore it.
+local host owns the new VG, and other hosts cannot use it.
 
 A VG without a system_id can be used by any host, and a VG with a
 system_id can only be used by a host with a matching system_id.  A
-"foreign VG" is a VG with a system_id as viewed by a host with a system_id
+.B foreign VG
+is a VG with a system_id as viewed by a host with a system_id
 that does not match the VG's system_id.  (Or from a host without a
 system_id.)
 
-To benefit fully from system_id, all hosts must have system_id set, and
-VGs must have system_id set.  Two hosts should not be assigned the same
-system_id.  Doing so defeats the purpose of the system_id.
-
 Valid system_id characters are the same as valid VG name characters.  If a
 system_id contains invalid characters, those characters are omitted and
 remaining characters are used.  If a system_id is longer than the maximum
 name length, the characters up to the maximum length are used.  The
-maximum length of a system_id is 128 characters.
+maximum length of a system_id is 127 characters.
+
+.SS Limitations and warnings
+
+To benefit fully from system_id, all hosts must have system_id set, and
+VGs must have system_id set.  A VG on shared storage can be corrupted or
+destroyed in the following cases which the user must be careful to avoid:
+
+.IP \[bu] 2
+A host using an old version of lvm without the system_id feature will not
+recognize the system_id of other hosts' VGs and will not be stopped from
+using them.
+
+.IP \[bu] 2
+A VG without a system_id can be used without restriction from any host,
+even from hosts that have a system_id.  Many VGs will not have a system_id
+and are unprotected.  Verify that a VG has a system_id by running the
+command 'vgs -o+systemid'
+
+A VG will not have a system_id if it was created before this feature was
+added to lvm, or if it was created by a host that did not have a system_id
+defined.  A system_id can be assigned to these VGs by using vgchange
+--systemid (see below).
+
+.IP \[bu] 2
+Two hosts should not be assigned the same system_id.  Doing so defeats
+the purpose of the system_id which is to distinguish different hosts.
+
+.IP \[bu] 2
+Orphan PVs (or unused devices) on shared storage are completely
+unprotected by the system_id feature.  Commands that use these PVs, such
+as vgcreate or vgextend, are not prevented from performing conflicting
+operations and corrupting the PVs.  See the
+.B orphans
+section for more information.
+
+.P
 
 .SS Types of VG access
 A "local VG" is meant to be used by a single host.
@@ -267,10 +300,10 @@ The effects of this are especially evident when lvm uses lvmetad caching.
 For example, if multiple hosts see an orphan PV, and one host creates a VG
 using the orphan, the other hosts will continue to report the PV as an
 orphan.  Nothing would automatically prevent the other hosts from using
-the newly allocated PV.  If the other hosts run a command to rescan
-devices, and update lvmetad, they would then recognize the PV has become
-used by another host.  A command that rescans devices could be pvscan
---cache, or vgs --foreign.
+the newly allocated PV and corrupting it.  If the other hosts run a
+command to rescan devices, and update lvmetad, they would then recognize
+the PV has been used by another host.  A command that rescans devices
+could be pvscan --cache, or vgs --foreign.
 
 .SH SEE ALSO
 .BR vgcreate (8),


