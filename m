From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:32 +0100
Subject: [PATCH 28/29] Check type is not NULL before access
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <1581e3f71c289f475b0d580154ec41c734ad3309.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error Dereference of null pointer

Check type before dereference and report internal error in case
it's undefined and return from the function.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9b8e3c1..6d8c8bb 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -273,6 +273,12 @@ static void _display_fields(struct dm_report *rh)
 			log_warn("%*.*s", (int) strlen(desc) + 7,
 				 (int) strlen(desc) + 7,
 				 "-------------------------------------------------------------------------------");
+
+			if (!type) {
+				log_error(INTERNAL_ERROR "Type is not defined.");
+				return;
+			}
+
 			log_warn("  %sall%-*s - %s", type->prefix,
 				 (int) (id_len - 3 - strlen(type->prefix)), "",
 				 "All fields in this section.");
-- 
1.7.3.2


