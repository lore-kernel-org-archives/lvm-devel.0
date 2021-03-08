From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:53 +0000 (GMT)
Subject: main - libdm-config: replace check for 0
Message-ID: <20210308144653.5C9DB3951829@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3cff64408d63dfae20e3e3b307915dc08436ef8
Commit:        d3cff64408d63dfae20e3e3b307915dc08436ef8
Parent:        ca12dae32b03c54509608621b9268853b030fd40
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 21:52:10 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

libdm-config: replace check for 0

No need to call strlen() when checking for zero length string.
---
 device_mapper/libdm-config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/device_mapper/libdm-config.c b/device_mapper/libdm-config.c
index 7ce5620c6..a4c79c20d 100644
--- a/device_mapper/libdm-config.c
+++ b/device_mapper/libdm-config.c
@@ -599,7 +599,7 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		match(TOK_IDENTIFIER);
 	}
 
-	if (!strlen(str)) {
+	if (!*str) {
 		log_error("Parse error at byte %" PRIptrdiff_t " (line %d): empty section identifier",
 			  p->tb - p->fb + 1, p->line);
 		return NULL;


