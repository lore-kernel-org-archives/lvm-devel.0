From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 26 Aug 2015 16:39:57 +0000 (UTC)
Subject: master - libdm: Drop ignored duplicate export designation.
Message-ID: <20150826163957.CEA2160334@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=746b1bcf2ad08b0a15dbf6ea0e140c2eb71ff87a
Commit:        746b1bcf2ad08b0a15dbf6ea0e140c2eb71ff87a
Parent:        34c956afc19cd8a1023444ee333983e8b840e759
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 26 17:30:36 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 26 17:30:36 2015 +0100

libdm: Drop ignored duplicate export designation.

dm_stats_create_region is now assigned to DM_1_02_106 by default:
the DM_1_02_104 .exported_symbols file entry was moved into
libdm-stats.c as:
  DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104)
so delete it from .exported_symbols.DM_1_02_104.
---
 libdm/.exported_symbols.DM_1_02_104 |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 712fcf2..f0a8ed9 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -6,7 +6,6 @@ dm_stats_bind_uuid
 dm_stats_buffer_destroy
 dm_stats_clear_region
 dm_stats_create
-dm_stats_create_region
 dm_stats_delete_region
 dm_stats_destroy
 dm_stats_get_area_start


