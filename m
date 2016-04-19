From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:16 +0000 (UTC)
Subject: master - lvmetad: add disabled state
Message-ID: <20160419164916.885BF60AA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a4ef8fa25e4a8e14bef132393070006819b30935
Commit:        a4ef8fa25e4a8e14bef132393070006819b30935
Parent:        e41ee70accbc604e3a7daea0ab10f9405e95a531
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 28 16:54:36 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:41:18 2016 -0500

lvmetad: add disabled state

A global flag in lvmetad indicates it has been disabled.
Other flags indicate the reason it was disabled.
These flags can be queried using get_global_info.

The lvmetactl debugging utility can set and clear the
disabled flag in lvmetad.  Nothing else sets the
disabled flag yet.

Commands will check these flags after connecting to
lvmetad.  If the disabled flag is set, the command
will not use the lvmetad cache, but revert to disk
scanning.

To test this feature:

$ lvmetactl get_global_info
response = "OK"
global_invalid = 0
global_disable = 0
disable_reason = "none"
token = "filter:3041577944"

$ vgs
(should report VGs from lvmetad)

$ lvmetactl set_global_disable 1

$ lvmetactl get_global_info
response = "OK"
global_invalid = 0
global_disable = 1
disable_reason = "DIRECT"
token = "filter:3041577944"

$ vgs
  WARNING: Not using lvmetad because the disable flag was set directly.
(should report VGs without contacting lvmetad)

$ lvmetactl set_global_disable 0

$ vgs
(should report VGs from lvmetad)
---
 daemons/lvmetad/lvmetactl.c    |   23 ++++++++++--
 daemons/lvmetad/lvmetad-core.c |   74 +++++++++++++++++++++++++++++++++++++++-
 lib/cache/lvmetad.c            |   49 ++++++++++++++++++++++++++
 lib/cache/lvmetad.h            |    3 ++
 4 files changed, 144 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index de40bef..90db173 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -37,11 +37,12 @@ int main(int argc, char **argv)
 		printf("lvmetactl dump\n");
 		printf("lvmetactl pv_list\n");
 		printf("lvmetactl vg_list\n");
+		printf("lvmetactl get_global_info\n");
 		printf("lvmetactl vg_lookup_name <name>\n");
 		printf("lvmetactl vg_lookup_uuid <uuid>\n");
 		printf("lvmetactl pv_lookup_uuid <uuid>\n");
 		printf("lvmetactl set_global_invalid 0|1\n");
-		printf("lvmetactl get_global_invalid\n");
+		printf("lvmetactl set_global_disable 0|1\n");
 		printf("lvmetactl set_vg_version <uuid> <name> <version>\n");
 		printf("lvmetactl vg_lock_type <uuid>\n");
 		return -1;
@@ -69,6 +70,12 @@ int main(int argc, char **argv)
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
+	} else if (!strcmp(cmd, "get_global_info")) {
+		reply = daemon_send_simple(h, "get_global_info",
+					   "token = %s", "skip",
+					   NULL);
+		printf("%s\n", reply.buffer.mem);
+
 	} else if (!strcmp(cmd, "set_global_invalid")) {
 		if (argc < 3) {
 			printf("set_global_invalid 0|1\n");
@@ -82,11 +89,19 @@ int main(int argc, char **argv)
 					   NULL);
 		print_reply(reply);
 
-	} else if (!strcmp(cmd, "get_global_invalid")) {
-		reply = daemon_send_simple(h, "get_global_info",
+	} else if (!strcmp(cmd, "set_global_disable")) {
+		if (argc < 3) {
+			printf("set_global_disable 0|1\n");
+			return -1;
+		}
+		val = atoi(argv[2]);
+
+		reply = daemon_send_simple(h, "set_global_info",
+					   "global_disable = " FMTd64, (int64_t) val,
+					   "disable_reason = %s", "DIRECT",
 					   "token = %s", "skip",
 					   NULL);
-		printf("%s\n", reply.buffer.mem);
+		print_reply(reply);
 
 	} else if (!strcmp(cmd, "set_vg_version")) {
 		if (argc < 5) {
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 090255a..1c2ac81 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -196,7 +196,14 @@ struct vg_info {
 	uint32_t flags; /* VGFL_ */
 };
 
-#define GLFL_INVALID 0x00000001
+#define GLFL_INVALID                   0x00000001
+#define GLFL_DISABLE                   0x00000002
+#define GLFL_DISABLE_REASON_DIRECT     0x00000004
+#define GLFL_DISABLE_REASON_LVM1       0x00000008
+#define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
+
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES)
+
 #define VGFL_INVALID 0x00000001
 
 typedef struct {
@@ -2601,9 +2608,42 @@ static response vg_remove(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+/*
+ * Whether lvmetad is disabled is determined only by the single
+ * flag GLFL_DISABLE.  The REASON flags are only explanatory
+ * additions to GLFL_DISABLE, and do not control the disabled state.
+ * The REASON flags can accumulate if multiple reasons exist for
+ * the disabled flag.  When clearing GLFL_DISABLE, all REASON flags
+ * are cleared.  The caller clearing GLFL_DISABLE should only do so
+ * when all the reasons for it have gone.
+ */
+
 static response set_global_info(lvmetad_state *s, request r)
 {
 	const int global_invalid = daemon_request_int(r, "global_invalid", -1);
+	const int global_disable = daemon_request_int(r, "global_disable", -1);
+	const char *reason;
+	uint32_t reason_flags = 0;
+
+	if ((reason = daemon_request_str(r, "disable_reason", NULL))) {
+		if (strstr(reason, "DIRECT"))
+			reason_flags |= GLFL_DISABLE_REASON_DIRECT;
+		if (strstr(reason, "LVM1"))
+			reason_flags |= GLFL_DISABLE_REASON_LVM1;
+		if (strstr(reason, "DUPLICATES"))
+			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
+	}
+
+	if (global_invalid != -1) {
+		DEBUGLOG(s, "set global info invalid from %d to %d",
+			 (s->flags & GLFL_INVALID) ? 1 : 0, global_invalid);
+	}
+
+	if (global_disable != -1) {
+		DEBUGLOG(s, "set global info disable from %d to %d %s",
+			 (s->flags & GLFL_DISABLE) ? 1 : 0, global_disable,
+			 reason ? reason : "");
+	}
 
 	if (global_invalid == 1)
 		s->flags |= GLFL_INVALID;
@@ -2611,6 +2651,15 @@ static response set_global_info(lvmetad_state *s, request r)
 	else if (global_invalid == 0)
 		s->flags &= ~GLFL_INVALID;
 
+	if (global_disable == 1) {
+		s->flags |= GLFL_DISABLE;
+		s->flags |= reason_flags;
+
+	} else if (global_disable == 0) {
+		s->flags &= ~GLFL_DISABLE;
+		s->flags &= ~GLFL_DISABLE_REASON_ALL;
+	}
+
 	return daemon_reply_simple("OK", NULL);
 }
 
@@ -2629,8 +2678,31 @@ static response set_global_info(lvmetad_state *s, request r)
 
 static response get_global_info(lvmetad_state *s, request r)
 {
+	char reason[REASON_BUF_SIZE];
+
+	/* This buffer should be large enough to hold all the possible reasons. */
+
+	memset(reason, 0, sizeof(reason));
+
+	if (s->flags & GLFL_DISABLE) {
+		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
+			 (s->flags & GLFL_DISABLE_REASON_DIRECT) ? "DIRECT," : "",
+			 (s->flags & GLFL_DISABLE_REASON_LVM1) ? "LVM1," : "",
+			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? "DUPLICATES," : "");
+	}
+
+	if (!reason[0])
+		strcpy(reason, "none");
+
+	DEBUGLOG(s, "global info invalid is %d disable is %d reason %s",
+		 (s->flags & GLFL_INVALID) ? 1 : 0,
+		 (s->flags & GLFL_DISABLE) ? 1 : 0, reason);
+
 	return daemon_reply_simple("OK", "global_invalid = " FMTd64,
 					 (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
+					 "global_disable = " FMTd64,
+					 (int64_t)((s->flags & GLFL_DISABLE) ? 1 : 0),
+					 "disable_reason = %s", reason,
 					 "token = %s",
 					 s->token[0] ? s->token : "none",
 					 NULL);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a680441..f2831f1 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2249,3 +2249,52 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 
 	return ret;
 }
+
+int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
+{
+	daemon_reply reply;
+	const char *reply_reason;
+	int ret = 0;
+
+	reply = daemon_send_simple(_lvmetad, "get_global_info",
+				   "token = %s", "skip",
+				   NULL);
+
+	if (reply.error) {
+		*reason = "send error";
+		ret = 1;
+		goto out;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		*reason = "response error";
+		ret = 1;
+		goto out;
+	}
+
+	if (daemon_reply_int(reply, "global_disable", 0)) {
+		ret = 1;
+
+		reply_reason = daemon_reply_str(reply, "disable_reason", NULL);
+
+		if (!reply_reason) {
+			*reason = "<not set>";
+
+		} else if (strstr(reply_reason, "DIRECT")) {
+			*reason = "the disable flag was set directly";
+
+		} else if (strstr(reply_reason, "LVM1")) {
+			*reason = "LVM1 metadata was found";
+
+		} else if (strstr(reply_reason, "DUPLICATES")) {
+			*reason = "duplicate PVs were found";
+
+		} else {
+			*reason = "<unknown>";
+		}
+	}
+out:
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 5820956..10283bb 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -172,6 +172,8 @@ int lvmetad_token_matches(struct cmd_context *cmd);
 
 int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
+int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason);
+
 #  else		/* LVMETAD_SUPPORT */
 
 #    define lvmetad_init(cmd)	do { } while (0)
@@ -202,6 +204,7 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 #    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
 #    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
 #    define lvmetad_token_matches(cmd) (1)
+#    define lvmetad_is_disabled(cmd, reason) (0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


