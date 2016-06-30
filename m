From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:07 +0000 (UTC)
Subject: master - cleanup: drop unused assignments
Message-ID: <20160630224607.1E10A611AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9d3e8c8a8cd5faf23e30336303f6aeef5c32804
Commit:        b9d3e8c8a8cd5faf23e30336303f6aeef5c32804
Parent:        1e3411aa3724ee9ee32f5cb4378526b9c355854d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 30 10:45:52 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:44:48 2016 +0200

cleanup: drop unused assignments

In all code paths we set a value for these variables, so drop
their initial unused assign.
---
 daemons/lvmetad/lvmetad-core.c        |    2 +-
 daemons/lvmpolld/lvmpolld-cmd-utils.c |    2 +-
 lib/cache/lvmetad.c                   |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1ec9e3b..31d0933 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2646,7 +2646,7 @@ static response dump(lvmetad_state *s)
 
 static response handler(daemon_state s, client_handle h, request r)
 {
-	response res = { 0 };
+	response res;
 	lvmetad_state *state = s.private;
 	char prev_token[128] = { 0 };
 	const char *rq;
diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
index 86f5000..f70fd0d 100644
--- a/daemons/lvmpolld/lvmpolld-cmd-utils.c
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -31,7 +31,7 @@ const char *polling_op(enum poll_type type)
 
 static int add_to_cmd_arr(const char ***cmdargv, const char *str, unsigned *ind)
 {
-	const char **newargv = *cmdargv;
+	const char **newargv;
 
 	if (*ind && !(*ind % MIN_ARGV_SIZE)) {
 		newargv = dm_realloc(*cmdargv, (*ind / MIN_ARGV_SIZE + 1) * MIN_ARGV_SIZE * sizeof(char *));
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 94059dd..476448d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -955,7 +955,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 {
 	struct volume_group *vg = NULL;
 	struct volume_group *vg2 = NULL;
-	daemon_reply reply = { 0 };
+	daemon_reply reply;
 	int found;
 	char uuid[64];
 	struct format_instance *fid = NULL;


