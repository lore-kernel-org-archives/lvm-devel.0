From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:15 +0000 (UTC)
Subject: master - libdm: fix string boundary
Message-ID: <20160223204115.8F736607C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d6e063a0fd132c49490f01949dfa5fa28125a33
Commit:        6d6e063a0fd132c49490f01949dfa5fa28125a33
Parent:        eccc91f9b0ef7387f46cdd93e3f44ab45e0c1ba3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 20:17:41 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:38:52 2016 +0100

libdm: fix string boundary

The test for string 'end' needs to account for ending \0,
which also needs to fit <SIZE.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-report.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3dbbfae..14793b3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.118 -
 =====================================
+  Fix string boundary check in _get_canonical_field_name().
   Always initialized hist struct in _stats_parse_histogram().
 
 Version 1.02.117 - 21st February 2016
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 55b5ff0..0163910 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -839,8 +839,9 @@ static int _get_canonical_field_name(const char *field,
 			diff = 1;
 			continue;
 		}
-		if (i >= fcanonical_len) {
-			log_error("%s: field name too long", field);
+		if ((i + 1) >= fcanonical_len) {
+			canonical_field[0] = '\0';
+			log_error("%s: field name too long.", field);
 			return 0;
 		}
 		canonical_field[i++] = *field;


