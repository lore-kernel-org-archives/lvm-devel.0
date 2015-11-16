From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 Nov 2015 22:27:34 +0000 (UTC)
Subject: master - lvmetad: add error explaining duplicate VG names
Message-ID: <20151116222734.2CC9F6010C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d42cedae5818a50edde3ddb1db4bec6a2591c920
Commit:        d42cedae5818a50edde3ddb1db4bec6a2591c920
Parent:        7d1c9e1d5a11e7e06c52036c380dd51a2c761f66
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 16:23:28 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 16 16:25:49 2015 -0600

lvmetad: add error explaining duplicate VG names

When a VG name lookup fails because the name matches
multiple VGs, return an explanatory error.
---
 daemons/lvmetad/lvmetad-core.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 2ceaa02..8e5bc37 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -741,8 +741,11 @@ static response vg_lookup(lvmetad_state *s, request r)
 			name = dm_hash_lookup(s->vgid_to_vgname, uuid);
 		unlock_vgid_to_metadata(s);
 
-		if (name && uuid && uuid2)
-			return reply_unknown("Multiple VGs found with same name");
+		if (name && uuid && uuid2) {
+			DEBUGLOG(s, "vg_lookup name %s found multiple vgids %s %s",
+				 name, uuid, uuid2);
+			return daemon_reply_simple("multiple", "reason = %s", "Multiple VGs found with same name", NULL);
+		}
 
 		if (!uuid || !name)
 			return reply_unknown("VG not found");


