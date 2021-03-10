From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:36 +0000 (GMT)
Subject: main - gcc: match size of holder name to direcnt d_name
Message-ID: <20210310003636.89C323858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15c588f931d3b30344352a49d7f8df6dc5ea873c
Commit:        15c588f931d3b30344352a49d7f8df6dc5ea873c
Parent:        75037bee5d92023718a1b9f0725152b4512e4349
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 13:58:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:28:08 2021 +0100

gcc: match size of holder name to direcnt d_name

As d_name is defined as 256 avoid gcc warning - although
in our case the used size will be much smaller.
---
 lib/filters/filter-mpath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 57ed79908..471f0b4b9 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -198,7 +198,7 @@ static int _native_dev_is_mpath_component(struct cmd_context *cmd, struct dev_fi
 	char link_path[PATH_MAX];       /* some obscure, unpredictable sysfs path */
 	char holders_path[PATH_MAX];    /* e.g. "/sys/block/sda/holders/" */
 	char dm_dev_path[PATH_MAX];    /* e.g. "/dev/dm-1" */
-	char holder_name[128] = { 0 };  /* e.g. "dm-1" */
+	char holder_name[256];		/* e.g. "dm-1" */
 	const char *sysfs_dir = dm_sysfs_dir();
 	int dev_major = MAJOR(dev->dev);
 	int dev_minor = MINOR(dev->dev);


