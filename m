From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:17 +0200
Subject: [PATCH 05/25] Replicator: add reserved names
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <de2dff73584c9ae4e362eddb246d42f1532881cd.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add new reserved names for replicator related devices.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/lvm-string.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 7eed799..fb73674 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -275,6 +275,24 @@ int apply_lvname_restrictions(const char *name)
 		return 0;
 	}
 
+	if (strstr(name, "_slog")) {
+		log_error("Names including \"_slog\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_rlog")) {
+		log_error("Names including \"_rlog\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
+	if (strstr(name, "_rimage")) {
+		log_error("Names including \"_rimage\" are reserved. "
+			  "Please choose a different LV name.");
+		return 0;
+	}
+
 	return 1;
 }
 
-- 
1.7.2.1


