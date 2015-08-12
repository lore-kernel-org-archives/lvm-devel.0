From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:10 +0000 (UTC)
Subject: master - config: extend definition for Allocation
Message-ID: <20150812124110.A0DD760A52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9edd2258ffc7ae7593a6e193760861090d0fb273
Commit:        9edd2258ffc7ae7593a6e193760861090d0fb273
Parent:        13c7bbf8a9ff2fad2718ba6cb627d7fcef766900
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 23 14:20:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:15 2015 +0200

config: extend definition for Allocation

Extend comment for this section.
---
 lib/config/config_settings.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index c8461f7..c2bef27 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -122,7 +122,8 @@ cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), 0
 	"How LVM uses block devices.\n")
 
 cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), 0, NULL,
-	"How LVM selects free space for Logical Volumes.\n")
+	"How LVM selects free space for Logical Volumes and default\n"
+	"properties applied to new Logical Volumes of various types.\n")
 
 cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM log information is reported.\n")


