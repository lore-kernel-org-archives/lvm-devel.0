From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  6 Aug 2013 14:23:14 +0000 (UTC)
Subject: master - libdm: update DM_ABORT_ON_INTERNAL_ERRORS
Message-ID: <20130806142314.94C1E61128@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16c1dacb6e98c8b49462a7ca9f98687c0affe498
Commit:        16c1dacb6e98c8b49462a7ca9f98687c0affe498
Parent:        139a62fc0bbe45318c7ca25cd8ee2dc990c95a9d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 6 15:22:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 6 16:19:31 2013 +0200

libdm: update DM_ABORT_ON_INTERNAL_ERRORS

Update behavior to disable  aborting when macro is unset
or its set to 0.  In other cases it will abort.
i.e. set to anything....
---
 libdm/libdm-common.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index de4b747..2e068dc 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -127,9 +127,9 @@ static void _default_log_line(int level,
 	}
 
 	if (_abort_on_internal_errors < 0)
-		/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is 1 */
+		/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is not "0" */
 		_abort_on_internal_errors =
-			!strcmp(getenv("DM_ABORT_ON_INTERNAL_ERRORS") ? : "0", "1");
+			strcmp(getenv("DM_ABORT_ON_INTERNAL_ERRORS") ? : "0", "0");
 
 	if (_abort_on_internal_errors &&
 	    !strncmp(f, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1))


