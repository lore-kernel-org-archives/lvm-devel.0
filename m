From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:32:19 +0000 (UTC)
Subject: master - WHATS_NEW update
Message-ID: <20140321213219.C649860DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93d77455eaa06c111954bc29c052fdaf4f31464e
Commit:        93d77455eaa06c111954bc29c052fdaf4f31464e
Parent:        c0c55846b0a08454c913758f2709888301835bef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 22:00:54 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:28 2014 +0100

WHATS_NEW update

---
 WHATS_NEW |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f07d2a9..bdfe111 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.02.106 - 
 ====================================
+  Reindent some clvmd.c code.
+  Use dm_malloc function in clvmd.c.
+  Resolve memory release order for clvmd shutdown.
+  Report error when lvm2 activation is released in critical_section.
   Fix memory corruption when pvscan reports long pv names.
   Do not report internal orphan VG names when reporting pvdisplay/pvscan.
   Fix pvdisplay -c man page referencing KB instead of sectors.


