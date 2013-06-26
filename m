From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:29 +0000 (UTC)
Subject: dev-peter-config-profiles - cleanup: use "" around type in error message
Message-ID: <20130626145529.6FF5A60E54@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da9263905c946914f0c18fc25fb0d4d34875fd1e
Commit:        da9263905c946914f0c18fc25fb0d4d34875fd1e
Parent:        19b064a30939df25ef1f31337ac6b566023b7793
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 24 12:00:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: use "" around type in error message

A bit more cleaner error message for wrong discards paramater.
---
 lib/metadata/thin_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index bd30458..7ddadcf 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -658,7 +658,7 @@ int get_pool_discards(const char *str, thin_discards_t *discards)
 	else if (!strcasecmp(str, "ignore"))
 		*discards = THIN_DISCARDS_IGNORE;
 	else {
-		log_error("Thin pool discards type %s is unknown.", str);
+		log_error("Thin pool discards type \"%s\" is unknown.", str);
 		return 0;
 	}
 


