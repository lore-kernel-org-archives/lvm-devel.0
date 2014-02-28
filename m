From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 15:24:37 +0000 (UTC)
Subject: master - format-text: Fix a warning.
Message-ID: <20140228152437.6ED0960EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb003cdfd5eee1d67887cd2136630cc36bba2cbf
Commit:        fb003cdfd5eee1d67887cd2136630cc36bba2cbf
Parent:        3e5bec37e9cec455f20656858ba510b69010676d
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 16:23:16 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 16:23:16 2014 +0100

format-text: Fix a warning.

---
 lib/format_text/format-text.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e0b2786..29df5f1 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1684,7 +1684,7 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
 	char mdah[MDA_HEADER_SIZE]; /* temporary */
 
-	if (!mdc || !_raw_read_mda_header(mdah, &mdc->area))
+	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,


