From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 15:03:02 +0000 (UTC)
Subject: master - lvmetead: release token
Message-ID: <20121012150302.F1101222C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee7143cd02d4b26c80b7accbb80d570058cbe9a9
Commit:        ee7143cd02d4b26c80b7accbb80d570058cbe9a9
Parent:        4d7a4554f40f990b9cb43a5a6039251eec3b94c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 16:50:38 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 17:01:22 2012 +0200

lvmetead: release token

Release allocated memory when destroing toolcontext
---
 lib/cache/lvmetad.c        |    6 ++++++
 lib/cache/lvmetad.h        |    5 +++++
 lib/commands/toolcontext.c |    3 +++
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 47a6d75..9c11329 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -86,6 +86,12 @@ void lvmetad_set_token(const struct dm_config_value *filter)
 		log_warn("WARNING: Failed to set lvmetad token. Out of memory?");
 }
 
+void lvmetad_release_token(void)
+{
+	dm_free(_lvmetad_token);
+	_lvmetad_token = NULL;
+}
+
 void lvmetad_set_socket(const char *sock)
 {
 	_lvmetad_socket = sock;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index f6e7b67..98d9034 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -64,6 +64,11 @@ void lvmetad_disconnect(void);
 void lvmetad_set_token(const struct dm_config_value *filter);
 
 /*
+ * Release allocated token.
+ */
+void lvmetad_release_token(void);
+
+/*
  * Send a new version of VG metadata to lvmetad. This is normally called after
  * vg_write but before vg_commit. After vg_commit, lvmetad_vg_commit is called
  * to seal the transaction. The result of lvmetad_vg_update is that the new
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 5177f41..d89d2b4 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1672,6 +1672,9 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	dm_free(cmd);
 
+	lvmetad_release_token();
+	lvmetad_disconnect();
+
 	release_log_memory();
 	activation_exit();
 	reset_log_duplicated();


