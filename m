From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  8 Oct 2015 18:26:39 +0000 (UTC)
Subject: master - man lvmsystemid: fix typos
Message-ID: <20151008182639.280C061141@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5446d177569ca10476c935013ae03e6a0763ab34
Commit:        5446d177569ca10476c935013ae03e6a0763ab34
Parent:        c9ff5c8223c6c2d23829aef076d58c32382891c8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 8 13:21:42 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 8 13:26:09 2015 -0500

man lvmsystemid: fix typos

---
 man/lvmsystemid.7.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/lvmsystemid.7.in b/man/lvmsystemid.7.in
index eb10ac5..0048873 100644
--- a/man/lvmsystemid.7.in
+++ b/man/lvmsystemid.7.in
@@ -274,7 +274,7 @@ cache with pvscan --cache will allow a host to recognize the newly
 exported VG.
 
 vgimport sets the VG system_id to the local system_id as determined by
-lvm.conf system_id_sources.  vgimport automatically scans storage for
+lvm.conf system_id_source.  vgimport automatically scans storage for
 newly exported VGs.
 
 After vgimport, the exporting host will continue to see the VG as
@@ -300,9 +300,9 @@ To move a VG from one host to another, vgexport and vgimport should be
 used.
 
 To forcibly gain ownership of a foreign VG, a host can add the foreign
-system_id to its allow_system_id list, change the system_id of the foreign
-VG to its own, and remove the foreign system_id from its allow_system_id
-list.
+system_id to its extra_system_ids list, change the system_id of the
+foreign VG to its own, and remove the foreign system_id from its
+extra_system_ids list.
 
 .SS shared VGs
 
@@ -328,7 +328,7 @@ creation_host will be the same.
 
 Orphan PVs are unused devices; they are not currently used in any VG.
 Because of this, they are not protected by a system_id, and any host can
-use them.  Coodination of changes to orphan PVs is beyond the scope of
+use them.  Coordination of changes to orphan PVs is beyond the scope of
 system_id.  The same is true of any block device that is not a PV.
 
 The effects of this are especially evident when lvm uses lvmetad caching.
@@ -337,7 +337,7 @@ using the orphan, the other hosts will continue to report the PV as an
 orphan.  Nothing would automatically prevent the other hosts from using
 the newly allocated PV and corrupting it.  If the other hosts run a
 command to rescan devices, and update lvmetad, they would then recognize
-the PV has been used by another host.  A command that rescans devices
+that the PV has been used by another host.  A command that rescans devices
 could be pvscan --cache, or vgs --foreign.
 
 .SH SEE ALSO


