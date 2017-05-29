From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 10:20:35 -0400
Subject: master - lvmetad: store MISSSING flag properly
Message-ID: <201705291420.v4TEKZ4U014914@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=148ad25f4c14274d920af477b1ca7084874eb615
Commit:        148ad25f4c14274d920af477b1ca7084874eb615
Parent:        4141409eb09e78aef030346995f1722fb40956d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 29 16:18:29 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 16:20:00 2017 +0200

lvmetad: store MISSSING flag properly

PV MISSING flag is compatible flag, not a status (incompatible) flag.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 878aa7a..0743c1f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Store MISSING PV in proper field in lvmetad.
   Cache format2 flag is now using segment name type field.
   Support storing status flags via segtype name field.
   Stop using '--yes' mode when fsadm runs without terminal.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index af5d429..242df98 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -360,7 +360,7 @@ static int update_pv_status(lvmetad_state *s,
 
 		pvmeta = dm_hash_lookup(s->pvid_to_pvmeta, uuid);
 
-		set_flag(cft, pv, "status", "MISSING", !pvmeta);
+		set_flag(cft, pv, "flags", "MISSING", !pvmeta);
 
 		if (pvmeta) {
 			if (!(pvmeta_cn = dm_config_clone_node(cft, pvmeta->root->child, 1))) {


