From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:26 +0000 (UTC)
Subject: master - lvmetad: check for fid existance
Message-ID: <20120622115126.8F53F1688@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9f9c6be26bb9c40269ebad6250e1a5b4759e74f
Commit:        e9f9c6be26bb9c40269ebad6250e1a5b4759e74f
Parent:        2539769356cd73ffe6ff7abd9f9c3208ff24ee8b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 13:43:55 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:50:21 2012 +0200

lvmetad: check for fid existance

Fail to update lvmetad with proper log error message.
---
 WHATS_NEW           |    1 +
 lib/cache/lvmetad.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ed1b37f..f1216ff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Check for create_instance() fail in pvscan_lvmetad_single().
   Use 64bit math for reserved memory and stack.
   Add tests for kernel_send() errors in cmirrod.
   Print clean_bits in pull_state, fix cut&paste typo in cmirrord.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 291adfa..d70e490 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -691,6 +691,9 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info),
 							     &fic);
 
+	if (!baton.fid)
+		goto_bad;
+
 	lvmcache_foreach_mda(info, _pvscan_lvmetad_single, &baton);
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);


