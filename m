From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:46 -0400
Subject: master - dmsetup: use dm_snprintf
Message-ID: <201803131204.w2DC4kck002616@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06c1f71897273558b5ffe607ceaee6d51576b861
Commit:        06c1f71897273558b5ffe607ceaee6d51576b861
Parent:        3f351466f7d2789b1f480cd0e370f978df8eb09b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:57:31 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: use dm_snprintf

---
 tools/dmsetup.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 88fb044..c866cd6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2297,7 +2297,6 @@ static int _mknodes(CMD_ARGS)
 
 static int _exec_command(const char *name)
 {
-	int n;
 	static char path[PATH_MAX];
 	static char *args[ARGS_MAX + 1];
 	static int argc = 0;
@@ -2310,8 +2309,7 @@ static int _exec_command(const char *name)
 	if (!dm_mknodes(name))
 		return_0;
 
-	n = snprintf(path, sizeof(path), "%s/%s", dm_dir(), name);
-	if (n < 0 || n > (int) sizeof(path) - 1)
+	if (dm_snprintf(path, sizeof(path), "%s/%s", dm_dir(), name) < 0)
 		return_0;
 
 	if (!argc) {


