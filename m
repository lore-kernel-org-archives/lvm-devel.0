From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:26 +0000 (GMT)
Subject: main - cov: ensure id is always initialize
Message-ID: <20211015214226.3A00A3858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2be6c38d5d878861b7d4ce601a64bcb88bbe38e
Commit:        c2be6c38d5d878861b7d4ce601a64bcb88bbe38e
Parent:        882141eb8c1a9718652cd903e411b6876aff54ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 15:00:03 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:40:56 2021 +0200

cov: ensure id is always initialize

Always resed sd_id128_t id and report warning in case
sd_id128_get_machine_app_specific() does not exit with 0.
---
 lib/commands/toolcontext.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ab574fb55..105aecd5d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -159,9 +159,11 @@ static const char *_system_id_from_source(struct cmd_context *cmd, const char *s
 
 #ifdef APP_MACHINEID_SUPPORT
 	if (!strcasecmp(source, "appmachineid")) {
-		sd_id128_t id;
+		sd_id128_t id = { 0 };
 
-		sd_id128_get_machine_app_specific(LVM_APPLICATION_ID, &id);
+		if (sd_id128_get_machine_app_specific(LVM_APPLICATION_ID, &id) != 0)
+			log_warn("WARNING: sd_id128_get_machine_app_specific() failed %s (%d).",
+				 strerror(errno), errno);
 
 		if (dm_snprintf(buf, PATH_MAX, SD_ID128_FORMAT_STR, SD_ID128_FORMAT_VAL(id)) < 0)
 			stack;


