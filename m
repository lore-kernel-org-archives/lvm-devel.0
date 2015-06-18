From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jun 2015 16:52:41 +0000 (UTC)
Subject: master - display: drop allocation from display_lvname
Message-ID: <20150618165241.E660360F08@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=438a65dfdb13abd10b3311e96786770d70868de1
Commit:        438a65dfdb13abd10b3311e96786770d70868de1
Parent:        a3e0d830bde952a83da3ba60936fff2fa7b40966
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 16 13:47:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 18 18:50:37 2015 +0200

display: drop allocation from display_lvname

Use of display_lvname() in plain log_debug() may accumulate memory in
command context mempool. Use instead small ringbuffer which allows to
store cuple (10 ATM) names so upto 10 full names can be used at one.

We are not keeping full VG/LV names as it may eventually consume larger
amount of RAM resouces if vgname is longer and lots of LVs are in use.

Note: if there would be ever needed for displaing more names at once,
the limit should be raised (e.g. log_debug() would need to print more
then 10 LVs on a single line).
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.h |    2 ++
 lib/display/display.c      |   19 +++++++++++++++++--
 3 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8d6e7f2..3ef783f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.122 - 
 =================================
+  Avoid allocation in display_lvname internal function.
   Support thins with size of external origin unaligned with thin pool chunk.
   Allow to extend reduced thin volumes with external origins.
   Consider snapshot and origin LV as unusable if its component is suspended.
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 28f5a2c..66bea5f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -146,6 +146,8 @@ struct cmd_context {
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
+	char display_buffer[NAME_LEN * 10];	/* Ring buffer for upto 10 longest vg/lv names */
+	unsigned display_lvname_idx;		/* Index to ring buffer */
 };
 
 /*
diff --git a/lib/display/display.c b/lib/display/display.c
index 2cc5d27..8f075d9 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -95,8 +95,23 @@ const char *get_percent_string(percent_type_t def)
 
 const char *display_lvname(const struct logical_volume *lv)
 {
-	/* On allocation failure, just return the LV name. */
-	return lv_fullname_dup(lv->vg->cmd->mem, lv) ? : lv->name;
+	char *name;
+	int r;
+
+	if ((lv->vg->cmd->display_lvname_idx + NAME_LEN) >= sizeof((lv->vg->cmd->display_buffer)))
+		lv->vg->cmd->display_lvname_idx = 0;
+
+	name = lv->vg->cmd->display_buffer + lv->vg->cmd->display_lvname_idx;
+	r = dm_snprintf(name, NAME_LEN, "%s/%s", lv->vg->name, lv->name);
+
+	if (r < 0) {
+		log_error("Full LV name \"%s/%s\" is too long.", lv->vg->name, lv->name);
+		return NULL;
+	}
+
+	lv->vg->cmd->display_lvname_idx += r;
+
+	return name;
 }
 
 #define BASE_UNKNOWN 0


