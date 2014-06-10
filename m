From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 10 Jun 2014 08:51:59 +0000 (UTC)
Subject: master - activation: retry cleanup deactivation
Message-ID: <20140610085159.6025F60B5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f260c99096c9db4aa6c3d3623739d18c203e1b4
Commit:        2f260c99096c9db4aa6c3d3623739d18c203e1b4
Parent:        1824a781db2dcdb328ba61893a1ace192cb78775
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 9 10:58:57 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 10 10:51:24 2014 +0200

activation: retry cleanup deactivation

Enable 'retry' deactivation also in 'cleanup' phase.
It shouldn't be mostly needed - however udev now produces
more and more completelny non-synchronizable device opens,
so even for orphan devices we can't easily predict where
udevd opens devices.

So it's more preferable here to log error about device being open
and retry clean, but let the command proceed.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 65cac33..4310dd1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use retry_deactivation also when cleaning orphan devices.
   Prompt when setting the VG cluster attr if the cluster is not setup.
   Allow --yes to skip prompt in vgextend (worked only with -f).
   Don't use name mangling for LVM - it never uses dm names with wrong char set.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cfceab5..22b13ec 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2816,6 +2816,8 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
 	switch(action) {
 	case CLEAN:
+		if (retry_deactivation())
+			dm_tree_retry_remove(root);
 		/* Deactivate any unused non-toplevel nodes */
 		if (!_clean_tree(dm, root, laopts->origin_only ? dlid : NULL))
 			goto_out;


