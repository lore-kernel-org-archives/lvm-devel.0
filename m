From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:10 +0200
Subject: [PATCH 03/30] Check (type) is not NULL before access
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <381373042f177c1ef15516a944adff25149c7a6f.1287994529.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clang Logic error	Dereference of null pointer

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7631e21..28b27b2 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -273,9 +273,10 @@ static void _display_fields(struct dm_report *rh)
 			log_warn("%*.*s", (int) strlen(desc) + 7,
 				 (int) strlen(desc) + 7,
 				 "-------------------------------------------------------------------------------");
-			log_warn("  %sall%-*s - %s", type->prefix,
-				 (int) (id_len - 3 - strlen(type->prefix)), "",
-				 "All fields in this section.");
+			if (type)
+				log_warn("  %sall%-*s - %s", type->prefix,
+					 (int) (id_len - 3 - strlen(type->prefix)), "",
+					 "All fields in this section.");
 		}
 
 		/* FIXME Add line-wrapping at terminal width (or 80 cols) */
-- 
1.7.3.1


