From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 Apr 2016 20:41:59 +0000 (UTC)
Subject: master - lvmetad: improve warning after lvmetad message fails
Message-ID: <20160427204159.E885761B86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=263c1a4db51184c718e85c1c3fdcef7908dd7c88
Commit:        263c1a4db51184c718e85c1c3fdcef7908dd7c88
Parent:        3c53acb378478f23acf624be8836c0cb24c2724e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 27 14:49:27 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 27 15:38:34 2016 -0500

lvmetad: improve warning after lvmetad message fails

Make it more consistent with the other similar warning.
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 8a1a2c5..8b63696 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -643,7 +643,7 @@ fail:
 	 * commands will not use it until it's been properly repopulated.
 	 */
 	if (action_modifies)
-		log_error("lvmetad update failed.  Restart lvmetad immediately.");
+		log_warn("WARNING: To avoid corruption, restart lvmetad (or disable with use_lvmetad=0).");
 
 	return 0;
 }


