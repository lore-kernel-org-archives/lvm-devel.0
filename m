From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Jul 2013 08:25:29 +0000 (UTC)
Subject: master - dumpconfig: honour --atversion with --type profilable
Message-ID: <20130709082529.838E160FFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=934616d4c759cd1dfe2b359fc83632999daf1ce8
Commit:        934616d4c759cd1dfe2b359fc83632999daf1ce8
Parent:        953a438e93a1adb0df7c7931cd6271b9d32acd7d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 9 10:23:46 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 9 10:23:46 2013 +0200

dumpconfig: honour --atversion with --type profilable

  raw/~ $ lvm dumpconfig --type profilable
  allocation {
	  thin_pool_zero=1
	  thin_pool_discards="passdown"
	  thin_pool_chunk_size=64
  }
  activation {
	  thin_pool_autoextend_threshold=100
	  thin_pool_autoextend_percent=20
  }

  raw/~ $ lvm dumpconfig --type profilable --atversion 2.2.90
  activation {
	  thin_pool_autoextend_threshold=100
	  thin_pool_autoextend_percent=20
  }
---
 lib/config/config.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 7c4f8ba..e18e623 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1371,7 +1371,8 @@ static int _should_skip_def_node(struct config_def_tree_spec *spec, int section_
 				return 1;
 			break;
 		case CFG_DEF_TREE_PROFILABLE:
-			if (!(def->flags & CFG_PROFILABLE))
+			if (!(def->flags & CFG_PROFILABLE) ||
+			    (def->since_version > spec->version))
 				return 1;
 			break;
 		default:


