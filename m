From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 28 Aug 2015 19:50:20 +0000 (UTC)
Subject: master - lvmetad: also accept vg name for set_vg_info
Message-ID: <20150828195020.AE36961028@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0b3e05addf7dfd3584904ff1f094b02664e0efd
Commit:        f0b3e05addf7dfd3584904ff1f094b02664e0efd
Parent:        09b2649c5fe4259a38265b80f4038b7481d03db2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 28 14:36:48 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 28 14:36:48 2015 -0500

lvmetad: also accept vg name for set_vg_info

set_vg_info previously accepted only vg uuid,
now accept both vg uuid and vg name.  If the
uuid is provided, it's used just as before,
but if the uuid is not provided, or if it's
not found, then fall back to using the vg
name if that is provided.
---
 daemons/lvmetad/lvmetactl.c    |   61 ++++++++++++++++++++++++++++------------
 daemons/lvmetad/lvmetad-core.c |   19 +++++++++---
 2 files changed, 57 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index 2c1c9b9..f524178 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -34,16 +34,16 @@ int main(int argc, char **argv)
 	int ver;
 
 	if (argc < 2) {
-		printf("lvmeta dump\n");
-		printf("lvmeta pv_list\n");
-		printf("lvmeta vg_list\n");
-		printf("lvmeta vg_lookup_name <name>\n");
-		printf("lvmeta vg_lookup_uuid <uuid>\n");
-		printf("lvmeta pv_lookup_uuid <uuid>\n");
-		printf("lvmeta set_global_invalid 0|1\n");
-		printf("lvmeta get_global_invalid\n");
-		printf("lvmeta set_vg_version <uuid> <version>\n");
-		printf("lvmeta vg_lock_type <uuid>\n");
+		printf("lvmetactl dump\n");
+		printf("lvmetactl pv_list\n");
+		printf("lvmetactl vg_list\n");
+		printf("lvmetactl vg_lookup_name <name>\n");
+		printf("lvmetactl vg_lookup_uuid <uuid>\n");
+		printf("lvmetactl pv_lookup_uuid <uuid>\n");
+		printf("lvmetactl set_global_invalid 0|1\n");
+		printf("lvmetactl get_global_invalid\n");
+		printf("lvmetactl set_vg_version <uuid> <name> <version>\n");
+		printf("lvmetactl vg_lock_type <uuid>\n");
 		return -1;
 	}
 
@@ -89,18 +89,43 @@ int main(int argc, char **argv)
 		printf("%s\n", reply.buffer.mem);
 
 	} else if (!strcmp(cmd, "set_vg_version")) {
-		if (argc < 4) {
-			printf("set_vg_version <uuid> <ver>\n");
+		if (argc < 5) {
+			printf("set_vg_version <uuid> <name> <ver>\n");
 			return -1;
 		}
 		uuid = argv[2];
-		ver = atoi(argv[3]);
+		name = argv[3];
+		ver = atoi(argv[4]);
+
+		if ((strlen(uuid) == 1) && (uuid[0] == '-'))
+			uuid = NULL;
+		if ((strlen(name) == 1) && (name[0] == '-'))
+			name = NULL;
+
+		if (uuid && name) {
+			reply = daemon_send_simple(h, "set_vg_info",
+						   "uuid = %s", uuid,
+						   "name = %s", name,
+						   "version = %d", ver,
+						    "token = %s", "skip",
+						    NULL);
+		} else if (uuid) {
+			reply = daemon_send_simple(h, "set_vg_info",
+						   "uuid = %s", uuid,
+						   "version = %d", ver,
+						    "token = %s", "skip",
+						    NULL);
+		} else if (name) {
+			reply = daemon_send_simple(h, "set_vg_info",
+						   "name = %s", name,
+						   "version = %d", ver,
+						    "token = %s", "skip",
+						    NULL);
+		} else {
+			printf("name or uuid required\n");
+			return -1;
+		}
 
-		reply = daemon_send_simple(h, "set_vg_info",
-					   "uuid = %s", uuid,
-					   "version = %d", ver,
-					   "token = %s", "skip",
-					   NULL);
 		print_reply(reply);
 
 	} else if (!strcmp(cmd, "vg_lookup_name")) {
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7b57dc4..19e8723 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1310,20 +1310,29 @@ static response set_vg_info(lvmetad_state *s, request r)
 {
 	struct dm_config_tree *vg;
 	struct vg_info *info;
-	const char *uuid = daemon_request_str(r, "uuid", NULL);
+	const char *name;
+	const char *uuid;
 	const int64_t new_version = daemon_request_int(r, "version", -1);
 	int64_t cache_version;
 
-	if (!uuid)
+	if (new_version == -1)
 		goto out;
 
-	if (new_version == -1)
+	if (!(uuid = daemon_request_str(r, "uuid", NULL)))
+		goto use_name;
+
+	if ((vg = dm_hash_lookup(s->vgid_to_metadata, uuid)))
+		goto vers;
+use_name:
+	if (!(name = daemon_request_str(r, "name", NULL)))
 		goto out;
 
-	vg = dm_hash_lookup(s->vgid_to_metadata, uuid);
-	if (!vg)
+	if (!(uuid = dm_hash_lookup(s->vgname_to_vgid, name)))
 		goto out;
 
+	if (!(vg = dm_hash_lookup(s->vgid_to_metadata, uuid)))
+		goto out;
+vers:
 	if (!new_version)
 		goto inval;
 


