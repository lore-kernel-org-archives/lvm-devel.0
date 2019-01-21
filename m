From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:38 -0500
Subject: master - vdo: size reduction requires VDO to be active
Message-ID: <201901211155.x0LBtcS3024501@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd6709cec6ca9ecc2c5f4e5f7d587daee5bd8cd1
Commit:        bd6709cec6ca9ecc2c5f4e5f7d587daee5bd8cd1
Parent:        f1ad4b067962c36e6f8199a8c6d10496bd9fb3b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jan 19 19:32:02 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: size reduction requires VDO to be active

To be able to send discard to reduced areas - the VDO LV needs to
be active.
---
 lib/metadata/lv_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1825abe..5418535 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4663,6 +4663,11 @@ static int _request_confirmation(const struct logical_volume *lv,
 			return 0;
 		}
 		return 1;
+	} else if (lv_is_vdo(lv) && !info.exists) {
+		log_error("Logical volume %s must be activated "
+			  "before reducing device size.",
+			  display_lvname(lv));
+		return 0;
 	}
 
 	if (!info.exists)


