From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:41 -0500
Subject: master - config: drop extra spaces
Message-ID: <201901081216.x08CGftZ031886@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61e378c4e72096be64cb5ee0a26cf976ad3a75e9
Commit:        61e378c4e72096be64cb5ee0a26cf976ad3a75e9
Parent:        fdd612b8242281ac599c220726155202c71549a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 7 17:39:55 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:13:57 2019 +0100

config: drop extra spaces

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 21ea3b6..eedb7cd 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -668,7 +668,7 @@ cfg(allocation_vdo_slab_size_mb_CFG, "vdo_slab_size_mb", allocation_CFG_SECTION,
 	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.")
 
 cfg(allocation_vdo_ack_threads_CFG, "vdo_ack_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_ACK_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
-	"Specifies the number of threads   to use for acknowledging\n"
+	"Specifies the number of threads to use for acknowledging\n"
 	"completion of requested VDO I/O operations.\n"
 	"The value must be at in range [0..100].\n")
 


