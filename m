From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 Apr 2016 18:22:17 +0000 (UTC)
Subject: master - cleanup: simplier to read condition
Message-ID: <20160408182217.B218D60309@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5cfa6cb347c5b7d8c5e3119b59bc7331388cb47e
Commit:        5cfa6cb347c5b7d8c5e3119b59bc7331388cb47e
Parent:        74e704bb4465960b361711c890733cbae1f06e42
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 8 19:34:56 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 8 20:20:16 2016 +0200

cleanup: simplier to read condition

Make more readable what we are looking for and just test for
KERNEL version at one place.
---
 lib/activate/dev_manager.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8c01b43..3f91654 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -669,14 +669,15 @@ static int _original_uuid_format_check_required(struct cmd_context *cmd)
 	static int _kernel_major = 0;
 
 	if (!_kernel_major) {
-		if ((sscanf(cmd->kernel_vsn, "%d", &_kernel_major) != 1))
-			_kernel_major = 1;
-		else if (_kernel_major >= MIN_KERNEL_MAJOR)
+		if ((sscanf(cmd->kernel_vsn, "%d", &_kernel_major) == 1) &&
+		    (_kernel_major >= MIN_KERNEL_MAJOR))
 			log_debug_activation("Skipping checks for old devices without " UUID_PREFIX
 					     " dm uuid prefix (kernel vsn %d >= %d).", _kernel_major, MIN_KERNEL_MAJOR);
+		else
+			_kernel_major = -1;
 	}
 
-	return (_kernel_major < MIN_KERNEL_MAJOR);
+	return (_kernel_major == -1);
 }
 
 static int _info(struct cmd_context *cmd, const char *dlid, int with_open_count, int with_read_ahead,


