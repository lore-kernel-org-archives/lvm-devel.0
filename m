From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:22 +0000 (UTC)
Subject: master - coverity: check for zero length buffer
Message-ID: <20160223204122.0D5A46104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eaaae185b7870372298502d076defab2c3486ed3
Commit:        eaaae185b7870372298502d076defab2c3486ed3
Parent:        b08eb91df132e84fa41b4cf06707629b2c5c895e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 19:54:19 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:16 2016 +0100

coverity: check for zero length buffer

When get_shared_library_path() would got zero length buffer,
it could have underflow in size calc later.
So just put extra small check for this case.
---
 lib/misc/sharedlib.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 28b8aae..db1ba43 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -27,10 +27,13 @@ void get_shared_library_path(struct cmd_context *cmd, const char *libname,
 {
 	struct stat info;
 
+	if (!path_len)
+		return;
+
 	/* If libname doesn't begin with '/' then use lib_dir/libname,
 	 * if present */
 	if (libname[0] == '/' ||
-            (!cmd->lib_dir &&
+	    (!cmd->lib_dir &&
 	     !(cmd->lib_dir = find_config_tree_str(cmd, global_library_dir_CFG, NULL))) ||
 	    (dm_snprintf(path, path_len, "%s/%s", cmd->lib_dir,
 			 libname) == -1) || stat(path, &info) == -1) {


