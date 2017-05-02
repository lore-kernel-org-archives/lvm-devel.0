From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 May 2017 15:59:00 -0400
Subject: master - man lvmsystemid: general improvements
Message-ID: <201705021959.v42Jx0DM011194@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=882a918befc8f09d30d913e66263b172dd503242
Commit:        882a918befc8f09d30d913e66263b172dd503242
Parent:        7da13bbf7baf161d275cc14fe1e5c97c50229e60
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 2 14:55:50 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 2 14:57:58 2017 -0500

man lvmsystemid: general improvements

Mainly improve the readability/wording.
Use "system ID" instead of system_id.
A couple small additions.
---
 man/lvmsystemid.7_main |  307 +++++++++++++++++++++++++++---------------------
 1 files changed, 174 insertions(+), 133 deletions(-)

diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 3aea996..1138e3f 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -5,132 +5,161 @@ lvmsystemid \(em LVM system ID
 
 .SH DESCRIPTION
 
-Local VGs may exist on shared storage where they are visible to multiple
-hosts.  These VGs are intended to be used by only a single machine, even
-though they are visible to many.  A system_id identifying a single host
-can be assigned to a VG to indicate the VGs owner.  The VG owner can use
-the VG as usual, and all other hosts will ignore it.  This protects the VG
-from accidental use by other hosts.
-
-The system_id is not a dynamic property, and can only be changed in very
-limited circumstances (see vgexport and vgimport).  Even limited changes
-to the VG system_id are not perfectly reflected across hosts.  A more
-coherent view of shared storage requires using an inter-host locking
-system to coordinate access and update caches.
-
-The system_id is a string uniquely identifying a host.  It can be manually
-set to a custom value or it can be assigned automatically by lvm using a
-unique identifier already available on the host, e.g. machine-id or uname.
-
-In vgcreate, the local system_id is saved in the new VG metadata.  The
-local host owns the new VG, and other hosts cannot use it.
-
-A VG without a system_id can be used by any host, and a VG with a
-system_id can only be used by a host with a matching system_id.  A
+The LVM system ID restricts VG access to one host.  This is useful when a
+VG is placed on shared storage devices, or when local devices are visible
+to both host and guest operating systems.  In cases like these, a VG can
+be visible to multiple hosts at once, and some mechanism is needed to
+protect it from being used by more than one host at a time.
+
+A VG's system ID identifies one host as the VG owner.  The host with a
+matching system ID can use the VG and its LVs, while LVM on other hosts
+will ignore it.  This protects the VG from being accidentally used from
+other hosts.
+
+The system ID is a string that uniquely identifies a host.  It can be
+configured as a custom value, or it can be assigned automatically by LVM
+using some unique identifier already available on the host, e.g.
+machine-id or uname.
+
+When a new VG is created, the system ID of the local host is recorded in
+the VG metadata.  The creating host then owns the new VG, and LVM on other
+hosts will ignore it.  When an existing, exported VG is imported
+(vgimport), the system ID of the local host is saved in the VG metadata,
+and the importing host owns the VG.
+
+A VG without a system ID can be used by LVM on any host where the VG's
+devices are visible.  When system IDs are not used, device filters should
+be configured on all hosts to exclude the VG's devices from all but one
+host.
+
+A
 .B foreign VG
-is a VG with a system_id as viewed by a host with a system_id
-that does not match the VGs system_id.  (Or from a host without a
-system_id.)
-
-Valid system_id characters are the same as valid VG name characters.  If a
-system_id contains invalid characters, those characters are omitted and
-remaining characters are used.  If a system_id is longer than the maximum
+is a VG seen by a host with an unmatching system ID, i.e. the system ID
+in the VG metadata does not match the system ID configured on the host.
+If the host has no system ID, and the VG does, the VG is foreign and LVM
+will ignore it.  If the VG has no system ID, access is unrestricted, and
+LVM can access it from any host, whether the host has a system ID or not.
+
+Changes to a host's system ID and a VG's system ID can be made in limited
+circumstances (see vgexport and vgimport).  Improper changes can result in
+a host losing access to its VG, or a VG being accidentally damaged by
+access from an unintended host.  Even limited changes to the VG system ID
+may not be perfectly reflected across hosts.  A more coherent view of
+shared storage requires an inter-host locking system to coordinate access
+and update caches.
+
+Valid system ID characters are the same as valid VG name characters.  If a
+system ID contains invalid characters, those characters are omitted and
+remaining characters are used.  If a system ID is longer than the maximum
 name length, the characters up to the maximum length are used.  The
-maximum length of a system_id is 128 characters.
+maximum length of a system ID is 128 characters.
+
+Print the system ID of a VG to check if it is set:
+
+.B vgs -o systemid
+.I VG
+
+Print the system ID of the local host to check if it is configured:
+
+.B lvm systemid
 
 .SS Limitations and warnings
 
-To benefit fully from system_id, all hosts must have system_id set, and
-VGs must have system_id set.  A VG on shared storage can be damaged or
-destroyed in some cases which the user must be careful to avoid.
+To benefit fully from system ID, all hosts should have a system ID
+configured, and all VGs should have a system ID set.  Without any method
+to restrict access, e.g. system ID or device filters, a VG that is visible
+to multiple hosts can be accidentally damaged or destroyed.
 
 .IP \[bu] 2
-A VG without a system_id can be used without restriction from any host,
-even from hosts that have a system_id.  Many VGs will not have a system_id
-and are unprotected.  Verify that a VG has a system_id by running the
-command 'vgs -o+systemid'
+A VG without a system ID can be used without restriction from any host
+where it is visible, even from hosts that have a system ID.
 
-A VG will not have a system_id if it was created before this feature was
-added to lvm, or if it was created by a host that did not have a system_id
-defined.  A system_id can be assigned to these VGs by using vgchange
---systemid (see below).
+.IP \[bu] 2
+Many VGs will not have a system ID set because LVM has not enabled it by
+default, and even when enabled, many VGs were created before the feature
+was added to LVM or enabled.  A system ID can be assigned to these VGs by
+using vgchange --systemid (see below).
 
 .IP \[bu] 2
-Two hosts should not be assigned the same system_id.  Doing so defeats
-the purpose of the system_id which is to distinguish different hosts.
+Two hosts should not be assigned the same system ID.  Doing so defeats
+the purpose of distinguishing different hosts with this value.
 
 .IP \[bu] 2
-Orphan PVs (or unused devices) on shared storage are completely
-unprotected by the system_id feature.  Commands that use these PVs, such
-as vgcreate or vgextend, are not prevented from performing conflicting
-operations and corrupting the PVs.  See the
+Orphan PVs (or unused devices) on shared storage are unprotected by the
+system ID feature.  Commands that use these PVs, such as vgcreate or
+vgextend, are not prevented from performing conflicting operations and
+corrupting the PVs.  See the
 .B orphans
 section for more information.
 
 .IP \[bu] 2
-A host using an old version of lvm without the system_id feature will not
-recognize a new system_id in VGs from other hosts.  Even though the old
-version of lvm is not blocked from reading a VG with a system_id, it is
-blocked from writing to the VG (or its LVs).  The new system_id changes
-the write mode of a VG, making it appear read-only to previous lvm
-versions.
+The system ID does not protect devices in VG from programs other than LVM.
 
-This also means that if a host downgrades its version of lvm, it would
-lose access to any VGs it had created with a system_id.  To avoid this,
-the system_id should be removed from VGs before downgrading to an lvm
-version without the system_id feature.
+.IP \[bu] 2
+A host using an old version of LVM without the system ID feature will not
+recognize a system ID in VGs from other hosts.  Even though the old
+version of LVM is not blocked from reading a VG with a system ID, it is
+blocked from writing to the VG (or its LVs).  The system ID feature
+changes the write mode of a VG, making it appear read-only to previous
+versions of LVM.
+
+This also means that if a host downgrades its version of LVM, it would
+lose access to any VGs it had created with a system ID.  To avoid this,
+the system ID should be removed from VGs before downgrading to an LVM
+version without the system ID feature.
 
-.P
 
 .SS Types of VG access
 
 A local VG is meant to be used by a single host.
-.br
+
 A shared or clustered VG is meant to be used by multiple hosts.
-.br
+
 These can be further distinguished as:
 
 .B Unrestricted:
-A local VG that has no system_id.  This VG type is unprotected and
+A local VG that has no system ID.  This VG type is unprotected and
 accessible to any host.
 
 .B Owned:
-A local VG that has a system_id set, as viewed from the one host with a
-matching system_id (the owner).  This VG type is by definition acessible.
+A local VG that has a system ID set, as viewed from the host with a
+matching system ID (the owner).  This VG type is acessible to the host.
 
 .B Foreign:
-A local VG that has a system_id set, as viewed from any host with an
-unmatching system_id (or no system_id).  It is owned by another host.
-This VG type is by definition not accessible.
+A local VG that has a system ID set, as viewed from any host with an
+unmatching system ID (or no system ID).  It is owned by another host.
+This VG type is not accessible to the host.
 
 .B Exported:
-A local VG that has been exported with vgexport and has no system_id.
+A local VG that has been exported with vgexport and has no system ID.
 This VG type can only be accessed by vgimport which will change it to
 owned.
 
 .B Shared:
-A shared or "lockd" VG has lock_type set and no system_id.
+A shared or "lockd" VG has the lock_type set and has no system ID.
 A shared VG is meant to be used on shared storage from multiple hosts,
 and is only accessible to hosts using lvmlockd. Applicable only if LVM
-is compiled with lockd support.
+is compiled with lvmlockd support.
 
 .B Clustered:
-A clustered or "clvm" VG has the clustered flag set and no system_id.
+A clustered or "clvm" VG has the clustered flag set and has no system ID.
 A clustered VG is meant to be used on shared storage from multiple hosts,
-and is only accessible to hosts using clvmd.
+and is only accessible to hosts using clvmd. Applicable only if LVM
+is compiled with clvm support.
+
 
-.SS system_id_source
+.SS Host system ID configuration 
 
-A host's own system_id can be defined in a number of ways.  lvm.conf
-global/system_id_source defines the method lvm will use to find the local
-system_id:
+A host's own system ID can be defined in a number of ways.  lvm.conf
+global/system_id_source defines the method LVM will use to find the local
+system ID:
 
 .TP
 .B none
 .br
 
-lvm will not use a system_id.  lvm is allowed to access VGs without a
-system_id, and will create new VGs without a system_id.  An undefined
+LVM will not use a system ID.  LVM is allowed to access VGs without a
+system ID, and will create new VGs without a system ID.  An undefined
 system_id_source is equivalent to none.
 
 .I lvm.conf
@@ -144,7 +173,7 @@ global {
 .B machineid
 .br
 
-The content of /etc/machine-id is used as the system_id if available.
+The content of /etc/machine-id is used as the system ID if available.
 See
 .BR machine-id (5)
 and
@@ -164,7 +193,7 @@ global {
 
 The string utsname.nodename from
 .BR uname (2)
-is used as the system_id.  A uname beginning with "localhost"
+is used as the system ID.  A uname beginning with "localhost"
 is ignored and equivalent to none.
 
 .I lvm.conf
@@ -178,7 +207,7 @@ global {
 .B lvmlocal
 .br
 
-The system_id is defined in lvmlocal.conf local/system_id.
+The system ID is defined in lvmlocal.conf local/system_id.
 
 .I lvm.conf
 .nf
@@ -198,7 +227,7 @@ local {
 .B file
 .br
 
-The system_id is defined in a file specified by lvm.conf
+The system ID is defined in a file specified by lvm.conf
 global/system_id_file.
 
 .I lvm.conf
@@ -211,20 +240,22 @@ global {
 
 .LP
 
-Changing system_id_source will often cause the system_id to change, which
-may prevent the host from using VGs that it previously used (see
-extra_system_ids below to handle this.)
+Changing system_id_source will likely cause the system ID of the host to
+change, which will prevent the host from using VGs that it previously used
+(see extra_system_ids below to handle this.)
 
-If a system_id_source other than none fails to resolve a system_id, the
-host will be allowed to access VGs with no system_id, but will not be
-allowed to access VGs with a defined system_id.
+If a system_id_source other than none fails to produce a system ID value,
+it is the equivalent of having none.  The host will be allowed to access
+VGs with no system ID, but will not be allowed to access VGs with a system
+ID set.
 
-.SS extra_system_ids
 
-In some cases, it may be useful for a host to access VGs with different
-system_id's, e.g. if a host's system_id changes, and it wants to use VGs
-that it created with its old system_id.  To allow a host to access VGs
-with other system_id's, those other system_id's can be listed in
+.SS Overriding system ID
+
+In some cases, it may be necessary for a host to access VGs with different
+system IDs, e.g. if a host's system ID changes, and it wants to use VGs
+that it created with its old system ID.  To allow a host to access VGs
+with other system IDs, those other system IDs can be listed in
 lvmlocal.conf local/extra_system_ids.
 
 .I lvmlocal.conf
@@ -234,106 +265,115 @@ local {
 }
 .fi
 
+A safer option may be configuring the extra values as needed on the
+command line as:
+.br
+\fB--config 'local/extra_system_ids=["\fP\fIid\fP\fB"]'\fP
+
+
 .SS vgcreate
 
-In vgcreate, the host running the command assigns its own system_id to the
-new VG.  To override this and set another system_id:
+In vgcreate, the host running the command assigns its own system ID to the
+new VG.  To override this and set another system ID:
 
 .B vgcreate --systemid
-.I SystemID VG Devices
+.I SystemID VG PVs
 
-Overriding the system_id makes it possible for a host to create a VG that
-it may not be able to use.  Another host with a system_id matching the one
-specified may not recognize the new VG without manually rescanning
+Overriding the host's system ID makes it possible for a host to create a
+VG that it may not be able to use.  Another host with a system ID matching
+the one specified may not recognize the new VG without manually rescanning
 devices.
 
 If the --systemid argument is an empty string (""), the VG is created with
-no system_id, making it accessible to other hosts (see warnings above.)
+no system ID, making it accessible to other hosts (see warnings above.)
+
 
 .SS report/display
 
-The system_id of a VG is displayed with the "systemid" reporting option.
+The system ID of a VG is displayed with the "systemid" reporting option.
 
 Report/display commands ignore foreign VGs by default.  To report foreign
 VGs, the --foreign option can be used.  This causes the VGs to be read
 from disk.  Because lvmetad caching is not used, this option can cause
 poor performance.
 
-.B vgs --foreign -o+systemid
+.B vgs --foreign -o +systemid
 
-When a host with no system_id sees foreign VGs, it warns about them as
-they are skipped.  The host should be assigned a system_id, after which
+When a host with no system ID sees foreign VGs, it warns about them as
+they are skipped.  The host should be assigned a system ID, after which
 standard reporting commands will silently ignore foreign VGs.
 
+
 .SS vgexport/vgimport
 
-vgexport clears the system_id.
+vgexport clears the system ID.
 
 Other hosts will continue to see a newly exported VG as foreign because of
 local caching (when lvmetad is used).  Manually updating the local lvmetad
 cache with pvscan --cache will allow a host to recognize the newly
 exported VG.
 
-vgimport sets the VG system_id to the local system_id as determined by
-lvm.conf system_id_source.  vgimport automatically scans storage for
-newly exported VGs.
+vgimport sets the VG system ID to the system ID of the host doing the
+import.  vgimport automatically scans storage for newly exported VGs.
+
+After vgimport, the exporting host may continue to see the VG as exported,
+and not owned by the new host.  Manually updating the local cache with
+pvscan --cache will allow a host to recognize the newly imported VG as
+foreign.
 
-After vgimport, the exporting host will continue to see the VG as
-exported, and not owned by the new host.  Manually updating the local
-cache with pvscan --cache will allow a host to recognize the newly
-imported VG as foreign.
 
 .SS vgchange
 
-A host can change the system_id of its own VGs, but the command requires
+A host can change the system ID of its own VGs, but the command requires
 confirmation because the host may lose access to the VG being changed:
 
 .B vgchange --systemid
 .I SystemID VG
 
-The system_id can be removed from a VG by specifying an empty string ("")
-as the new system_id.  This makes the VG accessible to other hosts (see
+The system ID can be removed from a VG by specifying an empty string ("")
+as the new system ID.  This makes the VG accessible to other hosts (see
 warnings above.)
 
-A host cannot directly change the system_id of a foreign VG.
+A host cannot directly change the system ID of a foreign VG.
 
 To move a VG from one host to another, vgexport and vgimport should be
 used.
 
-To forcibly gain ownership of a foreign VG, a host can add the foreign
-system_id to its extra_system_ids list, change the system_id of the
-foreign VG to its own, and remove the foreign system_id from its
-extra_system_ids list.
+To forcibly gain ownership of a foreign VG, a host can temporarily add the
+foreign system ID to its extra_system_ids list, and change the system ID
+of the foreign VG to its own.  See Overriding system ID above.
+
 
 .SS shared VGs
 
-A shared/lockd VG has no system_id set, allowing multiple hosts to
-use it via lvmlockd.  Changing a VG to a lockd type will clear the
-existing system_id. Applicable only if LVM is compiled with lockd
-support.
+A shared/lockd VG has no system ID set, allowing multiple hosts to use it
+via lvmlockd.  Changing a VG to a lockd type will clear the existing
+system ID.  Applicable only if LVM is compiled with lockd support.
+
 
 .SS clustered VGs
 
-A clustered/clvm VG has no system_id set, allowing multiple hosts to
-use it via clvmd.  Changing a VG to clustered will clear the existing
-system_id.  Changing a VG to not clustered will set the system_id to the
-host running the vgchange command.
+A clustered/clvm VG has no system ID set, allowing multiple hosts to use
+it via clvmd.  Changing a VG to clustered will clear the existing system
+ID.  Changing a VG to not clustered will set the system ID to the host
+running the vgchange command.
+
 
 .SS creation_host
 
 In vgcreate, the VG metadata field creation_host is set by default to the
 host's uname.  The creation_host cannot be changed, and is not used to
 control access.  When system_id_source is "uname", the system_id and
-creation_host will be the same.
+creation_host fields will be the same.
 
 .SS orphans
 
 Orphan PVs are unused devices; they are not currently used in any VG.
-Because of this, they are not protected by a system_id, and any host can
+Because of this, they are not protected by a system ID, and any host can
 use them.  Coordination of changes to orphan PVs is beyond the scope of
-system_id.  The same is true of any block device that is not a PV.
+system ID.  The same is true of any block device that is not a PV.
 
-The effects of this are especially evident when lvm uses lvmetad caching.
+The effects of this are especially evident when LVM uses lvmetad caching.
 For example, if multiple hosts see an orphan PV, and one host creates a VG
 using the orphan, the other hosts will continue to report the PV as an
 orphan.  Nothing would automatically prevent the other hosts from using
@@ -347,8 +387,9 @@ could be pvscan --cache, or vgs --foreign.
 .BR vgchange (8),
 .BR vgimport (8),
 .BR vgexport (8),
+.BR vgs (8),
+.BR lvmlockd (8),
 .BR lvm.conf (5),
 .BR machine-id (5),
-.BR uname (2),
-.BR vgs (8)
+.BR uname (2)
 


