From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 22:56:50 +0000 (UTC)
Subject: master - man lvmsystemid: update changing the system_id
Message-ID: <20150220225650.DCFA260EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42ba7974c5e85f3b86807dacaf5f70a722475b52
Commit:        42ba7974c5e85f3b86807dacaf5f70a722475b52
Parent:        cfd1b8eae2e2cf30768603d11756f6ec9316958a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 16:55:27 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 16:55:27 2015 -0600

man lvmsystemid: update changing the system_id

---
 man/lvmsystemid.7.in |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index 9e3e6f8..c0dd78b 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -5,10 +5,10 @@ lvmsystemid \(em LVM system id
 
 .SH DESCRIPTION
 
-Local VG's may exist on shared storage where they are visible to multiple
-hosts.  These VG's are intended to be used by only a single machine, even
+Local VGs may exist on shared storage where they are visible to multiple
+hosts.  These VGs are intended to be used by only a single machine, even
 though they are visible to many.  A system_id identifying a single host
-can be assigned to a VG to indicate the VG's owner.  The VG owner can use
+can be assigned to a VG to indicate the VGs owner.  The VG owner can use
 the VG as usual, and all other hosts will ignore it.  This protects the VG
 from accidental use by other hosts.
 
@@ -29,7 +29,7 @@ A VG without a system_id can be used by any host, and a VG with a
 system_id can only be used by a host with a matching system_id.  A
 .B foreign VG
 is a VG with a system_id as viewed by a host with a system_id
-that does not match the VG's system_id.  (Or from a host without a
+that does not match the VGs system_id.  (Or from a host without a
 system_id.)
 
 Valid system_id characters are the same as valid VG name characters.  If a
@@ -236,8 +236,9 @@ devices.
 The system_id of a VG is displayed with the "systemid" reporting option.
 
 Report/display commands ignore foreign VGs by default.  To report foreign
-VGs, the --foreign option can be used.  This causes all VGs to be read
-from disk.
+VGs, the --foreign option can be used.  This causes the VGs to be read
+from disk.  Because lvmetad caching is not used, this option can cause
+poor performance.
 
 .B vgs --foreign -o+systemid
 
@@ -265,16 +266,22 @@ imported VG as foreign.
 
 .SS vgchange
 
-If a VG has a system_id, changing it with vgchange requires --force.
-vgchange --systemid is accepted just as with vgcreate.
+A host can change the system_id of its own VGs, but the command requires
+confirmation because the host may lose access to the VG being changed:
 
-If a host's system_id is changed, the system_id of its own VG's can be
-changed to match.  Using allow_system_id is a way to avoid using force
-with vgchange.
+.B vgchange --systemid
+.I SystemID VG
+
+A host cannot directly change the system_id of a foreign VG.
 
 To move a VG from one host to another, vgexport and vgimport should be
 used.
 
+To forcibly gain ownership of a foreign VG, a host can add the foreign
+system_id to its allow_system_id list, change the system_id of the foreign
+VG to its own, and remove the foreign system_id from its allow_system_id
+list.
+
 .SS clustered VGs
 
 A "clustered" VG should have no system_id set, allowing multiple hosts to


