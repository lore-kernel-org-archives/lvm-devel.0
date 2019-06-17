From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 17 Jun 2019 13:10:20 -0400
Subject: master - config: Fix default option which makes no sense
Message-ID: <201906171710.x5HHAKXT014279@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=556dcd2c6b82ead3a5aa50211f08f9d69be13fe1
Commit:        556dcd2c6b82ead3a5aa50211f08f9d69be13fe1
Parent:        7c697c1058ed32ca6311c3fd4e05f1b444e72aa1
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Jun 17 19:08:28 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Jun 17 19:08:28 2019 +0200

config: Fix default option which makes no sense

Default value is either undefined or commented, never both.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7851a76..527d5bd 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1694,7 +1694,7 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG
 	"and allows you to control which metadata areas are used at the\n"
 	"individual PV level using pvchange --metadataignore y|n.\n")
 
-cfg_runtime(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(1, 0, 0), 0, NULL,
+cfg_runtime(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(1, 0, 0), 0, NULL,
 	"The default size of the metadata area in units of 512 byte sectors.\n"
 	"The metadata area begins at an offset of the page size from the start\n"
 	"of the device. The first PE is by default at 1 MiB from the start of\n"


