From: Paul Bolle <pebolle@tiscali.nl>
Date: Sun, 09 Jan 2011 01:19:54 +0100
Subject: [PATCH] [TRIVIAL] Don't print char type[8] as a plain string
Message-ID: <1294532396.1957.5.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
diff -up LVM2.2.02.79/lib/metadata/metadata.c.pvck LVM2.2.02.79/lib/metadata/metadata.c
--- LVM2.2.02.79/lib/metadata/metadata.c.pvck	2010-12-14 18:51:09.000000000 +0100
+++ LVM2.2.02.79/lib/metadata/metadata.c	2011-01-09 00:45:19.000000000 +0100
@@ -3588,7 +3588,7 @@ int pv_analyze(struct cmd_context *cmd, 
 		return 0;
 	}
 
-	log_print("Found label on %s, sector %"PRIu64", type=%s",
+	log_print("Found label on %s, sector %"PRIu64", type=%.8s",
 		  pv_name, label->sector, label->type);
 
 	/*



