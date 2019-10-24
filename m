From: David Teigland <teigland@sourceware.org>
Date: Thu, 24 Oct 2019 11:27:39 -0400
Subject: stable-2.02 - config: allow_mixed_block_sizes set default to 1
Message-ID: <201910241527.x9OFRdQ7001407@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f53cce1804236e69b0ec99f490f0c2d2d001cf5d
Commit:        f53cce1804236e69b0ec99f490f0c2d2d001cf5d
Parent:        e298a87f71927987c2c324e2a53e1b4cd840f186
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 24 10:02:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 24 10:26:28 2019 -0500

config: allow_mixed_block_sizes set default to 1

to use the old behavior by default, which allows
using mixed block sizes.  The user will need to
set it to 0 in lvm.conf to turn on the new restrictions.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7981d5d..498ec23 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -470,7 +470,7 @@ cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_
 	"Enabling this setting allows the VG to be used as usual even with\n"
 	"uncertain devices.\n")
 
-cfg(devices_allow_mixed_block_sizes_CFG, "allow_mixed_block_sizes", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 6), NULL, 0, NULL,
+cfg(devices_allow_mixed_block_sizes_CFG, "allow_mixed_block_sizes", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 3, 6), NULL, 0, NULL,
 	"Allow PVs in the same VG with different logical block sizes.\n"
 	"When allowed, the user is responsible to ensure that an LV is\n"
 	"using PVs with matching block sizes when necessary.\n")


