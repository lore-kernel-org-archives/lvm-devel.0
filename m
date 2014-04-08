From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:03:04 +0000 (UTC)
Subject: master - cleanup: reindent return
Message-ID: <20140408090304.31AC960D76@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a41ab41b704ace5a82efada9acd76965c6274078
Commit:        a41ab41b704ace5a82efada9acd76965c6274078
Parent:        c1ae39e2ef9e4b31faf655f321ada0b4a3049426
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:45:37 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:16 2014 +0200

cleanup: reindent return

Since the return here is the only path, reindent for readability.
---
 libdm/libdm-common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 5c8b49c..f404c63 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1595,8 +1595,8 @@ int dm_set_sysfs_dir(const char *sysfs_dir)
 		_sysfs_dir[0] = '\0';
 		return 1;
 	}
-	else
-		return _canonicalize_and_set_dir(sysfs_dir, NULL, sizeof _sysfs_dir, _sysfs_dir);
+
+	return _canonicalize_and_set_dir(sysfs_dir, NULL, sizeof _sysfs_dir, _sysfs_dir);
 }
 
 const char *dm_sysfs_dir(void)


