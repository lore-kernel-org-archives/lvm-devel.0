From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 28 Jun 2021 18:42:25 +0000 (GMT)
Subject: master - config_settings: typo fix
Message-ID: <20210628184225.2EA19398B403@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9cb1d398320420280cd7dde28fca77d2459457c
Commit:        d9cb1d398320420280cd7dde28fca77d2459457c
Parent:        73a05c8f02e9e4575b1ffceebc3a907f2e43517b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 28 17:48:01 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 28 18:11:14 2021 +0200

config_settings: typo fix

---
 conf/example.conf.in         | 2 +-
 lib/config/config_settings.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index b4a55ae6a..16b49a495 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -723,7 +723,7 @@ allocation {
 	# vdo_write_policy = "auto"
 
 	# Configuration option allocation/vdo_max_discard.
-	# Specified te maximum size of discard bio accepted, in 4096 byte blocks.
+	# Specified the maximum size of discard bio accepted, in 4096 byte blocks.
 	# I/O requests to a VDO volume are normally split into 4096-byte blocks,
 	# and processed up to 2048 at a time. However, discard requests to a VDO volume
 	# can be automatically split to a larger size, up to <max discard> 4096-byte blocks
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d3a42a153..fe14a1eb2 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -807,7 +807,7 @@ cfg(allocation_vdo_write_policy_CFG, "vdo_write_policy", allocation_CFG_SECTION,
 	"        Data which has not been flushed is not guaranteed to persist in this mode.\n")
 
 cfg(allocation_vdo_max_discard_CFG, "vdo_max_discard", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_MAX_DISCARD, VDO_1ST_VSN, NULL, 0, NULL,
-	"Specified te maximum size of discard bio accepted, in 4096 byte blocks.\n"
+	"Specified the maximum size of discard bio accepted, in 4096 byte blocks.\n"
 	"I/O requests to a VDO volume are normally split into 4096-byte blocks,\n"
 	"and processed up to 2048 at a time. However, discard requests to a VDO volume\n"
 	"can be automatically split to a larger size, up to <max discard> 4096-byte blocks\n"


