From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 08:19:45 +0000 (UTC)
Subject: master - coverity: fix warnings about missing return value check for sscanf
Message-ID: <20160531081945.CBD9760B3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d333e5a296eba8ba2858ca007699fe70ec8083e
Commit:        3d333e5a296eba8ba2858ca007699fe70ec8083e
Parent:        48877e215d882f89294396d79f5d8d71395e427d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 31 10:06:19 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 31 10:06:25 2016 +0200

coverity: fix warnings about missing return value check for sscanf

All the variables for sscanf in lvmlockctl.c and lvmlockd-sanlock.c are
zeroed before sscanf call so the failure is detected by seeing the zero
value instead of proper one in subsequent code - so use (void) for
sscanf calls to ignore return value here.
---
 daemons/lvmlockd/lvmlockctl.c       |   12 ++++++------
 daemons/lvmlockd/lvmlockd-sanlock.c |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 4f559cf..7d4e072 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -77,7 +77,7 @@ static void save_client_info(char *line)
 	uint32_t client_id = 0;
 	char name[MAX_NAME+1] = { 0 };
 
-	sscanf(line, "info=client pid=%u fd=%d pi=%d id=%u name=%s",
+	(void) sscanf(line, "info=client pid=%u fd=%d pi=%d id=%u name=%s",
 	       &pid, &fd, &pi, &client_id, name);
 
 	clients[num_clients].client_id = client_id;
@@ -110,7 +110,7 @@ static void format_info_ls(char *line)
 	char lock_args[MAX_ARGS+1] = { 0 };
 	char lock_type[MAX_NAME+1] = { 0 };
 
-	sscanf(line, "info=ls ls_name=%s vg_name=%s vg_uuid=%s vg_sysid=%s vg_args=%s lm_type=%s",
+	(void) sscanf(line, "info=ls ls_name=%s vg_name=%s vg_uuid=%s vg_sysid=%s vg_args=%s lm_type=%s",
 	       ls_name, vg_name, vg_uuid, vg_sysid, lock_args, lock_type);
 
 	if (!first_ls)
@@ -131,7 +131,7 @@ static void format_info_ls_action(char *line)
 	uint32_t pid = 0;
 	char cl_name[MAX_NAME+1] = { 0 };
 
-	sscanf(line, "info=ls_action client_id=%u %s %s op=%s",
+	(void) sscanf(line, "info=ls_action client_id=%u %s %s op=%s",
 	       &client_id, flags, version, op);
 
 	find_client_info(client_id, &pid, cl_name);
@@ -147,7 +147,7 @@ static void format_info_r(char *line, char *r_name_out, char *r_type_out)
 	char sh_count[MAX_NAME+1] = { 0 };
 	uint32_t ver = 0;
 
-	sscanf(line, "info=r name=%s type=%s mode=%s %s version=%u",
+	(void) sscanf(line, "info=r name=%s type=%s mode=%s %s version=%u",
 	       r_name, r_type, mode, sh_count, &ver);
 
 	strcpy(r_name_out, r_name);
@@ -185,7 +185,7 @@ static void format_info_lk(char *line, char *r_name, char *r_type)
 		return;
 	}
 
-	sscanf(line, "info=lk mode=%s version=%u %s client_id=%u",
+	(void) sscanf(line, "info=lk mode=%s version=%u %s client_id=%u",
 	       mode, &ver, flags, &client_id);
 
 	find_client_info(client_id, &pid, cl_name);
@@ -221,7 +221,7 @@ static void format_info_r_action(char *line, char *r_name, char *r_type)
 		return;
 	}
 
-	sscanf(line, "info=r_action client_id=%u %s %s op=%s rt=%s mode=%s %s %s %s",
+	(void) sscanf(line, "info=r_action client_id=%u %s %s op=%s rt=%s mode=%s %s %s %s",
 	       &client_id, flags, version, op, rt, mode, lm, result, lm_rv);
 
 	find_client_info(client_id, &pid, cl_name);
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index b47c7f0..e344cb1 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -276,8 +276,8 @@ static int read_host_id_file(void)
 		*sep = '\0';
 		memset(key_str, 0, sizeof(key_str));
 		memset(val_str, 0, sizeof(val_str));
-		sscanf(key, "%s", key_str);
-		sscanf(val, "%s", val_str);
+		(void) sscanf(key, "%s", key_str);
+		(void) sscanf(val, "%s", val_str);
 
 		if (!strcmp(key_str, "host_id")) {
 			host_id = atoi(val_str);


