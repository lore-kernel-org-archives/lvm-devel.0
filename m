From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 05 Mar 2009 11:05:47 -0500
Subject: [PATCH] Fix typos in _read_pv function
Message-ID: <49AFF85B.3090609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a patch to fix typos in _read_pv() function.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/import_vsn1.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.02.46/lib/format_text/import_vsn1.c
===================================================================
--- LVM2.02.46.orig/lib/format_text/import_vsn1.c
+++ LVM2.02.46/lib/format_text/import_vsn1.c
@@ -179,7 +179,7 @@ static int _read_pv(struct format_instan
 	}
 
 	if (!_read_id(&pv->id, pvn, "id")) {
-		log_error("Couldn't read uuid for volume group.");
+		log_error("Couldn't read uuid for physical volume.");
 		return 0;
 	}
 
@@ -213,7 +213,7 @@ static int _read_pv(struct format_instan
 	_read_int64(pvn, "dev_size", &pv->size);
 
 	if (!_read_int64(pvn, "pe_start", &pv->pe_start)) {
-		log_error("Couldn't read extent size for volume group.");
+		log_error("Couldn't read extent size for physical volume.");
 		return 0;
 	}
 


