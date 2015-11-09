From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:24 +0000 (UTC)
Subject: master - libdm: add missing error path check
Message-ID: <20151109092824.B575260DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1c4017743060a25a6a263244d9d0e18c09acda5
Commit:        b1c4017743060a25a6a263244d9d0e18c09acda5
Parent:        18fd0bd20ce1d4a7d2bd27b2c9981a402f9bcd2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:31:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

libdm: add missing error path check

Coverity: do not continue with section cloning when root node
would a NULL.
---
 libdm/libdm-config.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index c8984b2..df314a0 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -563,7 +563,8 @@ static struct dm_config_node *_section(struct parser *p, struct dm_config_node *
 		return NULL;
 	}
 
-	root = _find_or_make_node(p->mem, parent, str);
+	if (!(root = _find_or_make_node(p->mem, parent, str)))
+		return_NULL;
 
 	if (p->t == TOK_SECTION_B) {
 		match(TOK_SECTION_B);


