From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 19 Mar 2009 11:40:11 -0400
Subject: [PATCH] Fix error message in create_text_format
Message-ID: <49C2675B.7080608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the error message in create_text_format
function.


Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.



Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/format-text.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.02.46-20090316/lib/format_text/format-text.c
===================================================================
--- LVM2.02.46-20090316.orig/lib/format_text/format-text.c
+++ LVM2.02.46-20090316/lib/format_text/format-text.c
@@ -1996,8 +1996,8 @@ struct format_type *create_text_format(s
 			}
 
 			if (!_add_dir(cv->v.str, &mda_lists->dirs)) {
-				log_error("Failed to add %s to internal device "
-					  "cache", cv->v.str);
+				log_error("Failed to add %s to text format "
+					  "metadata directory list ", cv->v.str);
 				goto err;
 			}
 		}


