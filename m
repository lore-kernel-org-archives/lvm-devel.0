From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 28 Aug 2015 19:50:22 +0000 (UTC)
Subject: master - lvmlockd: also use vg name in set_vg_info
Message-ID: <20150828195022.C4B1B6032D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b6226997eecb35560fd32fcb571478971024bd1
Commit:        8b6226997eecb35560fd32fcb571478971024bd1
Parent:        f0b3e05addf7dfd3584904ff1f094b02664e0efd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 28 14:40:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 28 14:43:58 2015 -0500

lvmlockd: also use vg name in set_vg_info

Include both the VG uuid and name in the lvmetad
set_vg_info message.  This works around an obscure
problem where the VG uuid in lvmlockd is wrong
when one host removes a dlm VG, then creates a new
VG with the same name.  If the dlm lockspace for
the initial VG was never stopped on another host,
that other host will be using the old uuid in its
lvmetad set_vg_info message.  (That can be
corrected with a larger change, but this is an
effective workaround.)
---
 daemons/lvmlockd/lvmlockd-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 14705b0..f2a01dc 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1100,7 +1100,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 				  ls->name, r->name, r_version);
 	
 			if (!ls->vg_uuid[0] || !strcmp(ls->vg_uuid, "none"))
-				uuid = ls->name;
+				uuid = (char *)"none";
 			else
 				uuid = ls->vg_uuid;
 
@@ -1108,6 +1108,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 			reply = daemon_send_simple(lvmetad_handle, "set_vg_info",
 						   "token = %s", "skip",
 						   "uuid = %s", uuid,
+						   "name = %s", ls->vg_name,
 						   "version = %d", (int)r_version,
 						   NULL);
 			pthread_mutex_unlock(&lvmetad_mutex);


