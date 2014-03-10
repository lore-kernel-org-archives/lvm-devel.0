From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:15 +0000 (UTC)
Subject: master - cleanup: clvmd use struct initializers
Message-ID: <20140310112715.3726D603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=341055ddb3bfaf3297aa068abf0d2412bc4cfd0b
Commit:        341055ddb3bfaf3297aa068abf0d2412bc4cfd0b
Parent:        c44ede31a39598c30634ff7b20e45e4600df5d37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 22:58:37 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

cleanup: clvmd use struct initializers

Simplify code, and use compiler capability to
initilize struct members on its own.
---
 daemons/clvmd/clvmd.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 43fecb6..1fc3694 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1121,15 +1121,13 @@ static int verify_message(char *buf, int len)
 
 static void dump_message(char *buf, int len)
 {
-	unsigned char row[8];
+	unsigned char row[8] = { 0 };
 	char str[9];
 	int i, j, pos = 0;
 
 	if (len > 128)
 		len = 128;
 
-	memset(row, 0, sizeof(row));
-
 	for (i = 0; i < len; i++) {
 		row[pos++] = buf[i];
 
@@ -1247,9 +1245,7 @@ static int read_from_local_sock(struct local_client *thisfd)
 	int len;
 	int argslen;
 	int missing_len;
-	char buffer[PIPE_BUF + 1];
-
-	memset(buffer, 0, sizeof(buffer));
+	char buffer[PIPE_BUF + 1] = { 0 };
 
 	len = read(thisfd->fd, buffer, sizeof(buffer) - 1);
 	if (len == -1 && errno == EINTR)
@@ -1982,7 +1978,11 @@ static void send_version_message(void)
 {
 	char message[sizeof(struct clvm_header) + sizeof(int) * 3];
 	struct clvm_header *msg = (struct clvm_header *) message;
-	int version_nums[3];
+	int version_nums[3] = {
+		htonl(CLVMD_MAJOR_VERSION),
+		htonl(CLVMD_MINOR_VERSION),
+		htonl(CLVMD_PATCH_VERSION)
+	};
 
 	msg->cmd = CLVMD_CMD_VERSION;
 	msg->status = 0;
@@ -1990,10 +1990,6 @@ static void send_version_message(void)
 	msg->clientid = 0;
 	msg->arglen = sizeof(version_nums);
 
-	version_nums[0] = htonl(CLVMD_MAJOR_VERSION);
-	version_nums[1] = htonl(CLVMD_MINOR_VERSION);
-	version_nums[2] = htonl(CLVMD_PATCH_VERSION);
-
 	memcpy(&msg->args, version_nums, sizeof(version_nums));
 
 	hton_clvm(msg);
@@ -2379,11 +2375,7 @@ static if_type_t get_cluster_type(void)
 	size_t namelen = sizeof(buf);
 	hdb_handle_t cluster_handle;
 	hdb_handle_t clvmd_handle;
-	confdb_callbacks_t callbacks = {
-		.confdb_key_change_notify_fn = NULL,
-		.confdb_object_create_change_notify_fn = NULL,
-		.confdb_object_delete_change_notify_fn = NULL
-	};
+	confdb_callbacks_t callbacks = { 0 };
 
 	result = confdb_initialize (&handle, &callbacks);
         if (result != CS_OK)


