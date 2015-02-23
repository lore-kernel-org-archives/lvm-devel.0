From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 17:10:13 +0000 (UTC)
Subject: master - lvm-string: Fix HYPEN typo.
Message-ID: <20150223171013.2B3EF60CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fcebf27a9ff52838e5730b82774effd1bf123b18
Commit:        fcebf27a9ff52838e5730b82774effd1bf123b18
Parent:        48478363109b1ea23a9f0acae8dbfd838cf925c6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 17:09:35 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 17:09:35 2015 +0000

lvm-string: Fix HYPEN typo.

---
 lib/display/display.c |    2 +-
 lib/misc/lvm-string.c |    2 +-
 lib/misc/lvm-string.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index f86b67f..b511b8e 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -855,7 +855,7 @@ void display_name_error(name_error_t name_error)
 	case NAME_INVALID_EMPTY:
 		log_error("Name is zero length.");
 		break;
-	case NAME_INVALID_HYPEN:
+	case NAME_INVALID_HYPHEN:
 		log_error("Name cannot start with hyphen.");
 		break;
 	case NAME_INVALID_DOTS:
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index f9cba31..61941b3 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -75,7 +75,7 @@ static name_error_t _validate_name(const char *n)
 
 	/* Hyphen used as VG-LV separator - ambiguity if LV starts with it */
 	if (*n == '-')
-		return NAME_INVALID_HYPEN;
+		return NAME_INVALID_HYPHEN;
 
 	if ((*n == '.') && (!n[1] || (n[1] == '.' && !n[2]))) /* ".", ".." */
 		return NAME_INVALID_DOTS;
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 0615f41..065c19f 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -28,7 +28,7 @@ struct logical_volume;
 typedef enum name_error {
 	NAME_VALID = 0,
 	NAME_INVALID_EMPTY = -1,
-	NAME_INVALID_HYPEN = -2,
+	NAME_INVALID_HYPHEN = -2,
 	NAME_INVALID_DOTS = -3,
 	NAME_INVALID_CHARSET = -4,
 	NAME_INVALID_LENGTH = -5


