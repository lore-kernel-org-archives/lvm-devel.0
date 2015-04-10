From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 10 Apr 2015 07:51:20 +0000 (UTC)
Subject: master - config: add note about 'vsn' macro use in config_settings.h
Message-ID: <20150410075120.9B88060DE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=463fd954bb87a9a565169a134f2d36acb6c7adf3
Commit:        463fd954bb87a9a565169a134f2d36acb6c7adf3
Parent:        4eaa399b54fb3cd7d30fd919666723159d9a04b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 10 09:50:10 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 10 09:51:08 2015 +0200

config: add note about 'vsn' macro use in config_settings.h

---
 lib/config/config_settings.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b55b39b..63332d4 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -66,6 +66,8 @@
  * since_version:	the version this configuration node first appeared in (be sure
  *			that parent nodes are consistent with versioning, no check done
  *			if parent node is older or the same age as any child node!)
+ *			Use "vsn" macro to translate the "major.minor.release" version
+ *			into a single number that is being stored internally in memory.
  */
 #include "defaults.h"
 


