From: David Teigland <teigland@sourceware.org>
Date: Fri, 22 Mar 2019 15:40:30 -0400
Subject: master - lvextend: refresh shared LV using select option
Message-ID: <201903221940.x2MJeUU2029105@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86b96ede2af32404d0b7b5f516a35dafc4da442e
Commit:        86b96ede2af32404d0b7b5f516a35dafc4da442e
Parent:        85e68a8333722b7694d607652dd1f834fadfd8c4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 22 14:28:02 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 22 14:35:02 2019 -0500

lvextend: refresh shared LV using select option

Using --select 'lvname=LV && vgname=VG' avoids the problem
of the lvchange exit code not distinguishing an actual error
result vs the VG or LV not existing.  (This is in case there
is an odd dlm/gfs2 setup where some nodes are running the dlm
but do not have access to the VG.)
---
 daemons/lvmlockd/lvmlockd-dlm.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 385d533..21aaa2d 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -781,15 +781,47 @@ int lm_is_running_dlm(void)
 
 int lm_refresh_lv_start_dlm(struct action *act)
 {
+	char path[PATH_MAX];
 	char command[DLMC_RUN_COMMAND_LEN];
 	char run_uuid[DLMC_RUN_UUID_LEN];
+	char *p, *vgname, *lvname;
 	int rv;
 
+	/* split /dev/vgname/lvname into vgname and lvname strings */
+	strncpy(path, act->path, strlen(act->path));
+
+	/* skip past dev */
+	p = strchr(path + 1, '/');
+
+	/* skip past slashes */
+	while (*p == '/')
+		p++;
+
+	/* start of vgname */
+	vgname = p;
+
+	/* skip past vgname */
+	while (*p != '/')
+		p++;
+
+	/* terminate vgname */
+	*p = '\0';
+	p++;
+
+	/* skip past slashes */
+	while (*p == '/')
+		p++;
+
+	lvname = p;
+
 	memset(command, 0, sizeof(command));
 	memset(run_uuid, 0, sizeof(run_uuid));
 
+	/* todo: add --readonly */
+
 	snprintf(command, DLMC_RUN_COMMAND_LEN,
-		 "lvm lvchange --refresh --nolocking %s", act->path);
+		 "lvm lvchange --refresh --partial --nolocking --select 'lvname=%s && vgname=%s'",
+		 lvname, vgname);
 
 	rv = dlmc_run_start(command, strlen(command), 0,
 			    DLMC_FLAG_RUN_START_NODE_NONE,


