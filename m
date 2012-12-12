From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Dec 2012 12:28:37 +0000 (UTC)
Subject: master - lvmetad: fix compiler warning and add WHATS_NEW line for previous commit
Message-ID: <20121212122837.D18F8246D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5709a32be746ad0d21b13df18f23387bcccabef
Commit:        e5709a32be746ad0d21b13df18f23387bcccabef
Parent:        f14f2d4378c066e50e2420e30407c8673cc7112a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 12 13:27:25 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 12 13:27:25 2012 +0100

lvmetad: fix compiler warning and add WHATS_NEW line for previous commit

---
 WHATS_NEW      |    1 +
 tools/pvscan.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dbd59bf..4214b27 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix crash in pvscan --cache -aay triggered by non-mda PV.
   Allow lvconvert --stripes/stripesize only with --mirrors/--repair/--thinpool.
   Fix memleak in device_is_usable mirror testing function.
   Do not ignore -f in lvconvert --repair -y -f for mirror and raid volumes.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 81849f5..c2e6f5c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -106,7 +106,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	id_read_format(&vgid_raw, vgid);
 	/* NB. This is safe because we know lvmetad is running and we won't hit
 	 * disk. */
-	if (!(vg = vg_read_internal(cmd, NULL, &vgid_raw, 0, &consistent)))
+	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))
 	    return 1;
 
 	if (vg_is_clustered(vg)) {


