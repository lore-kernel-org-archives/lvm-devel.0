From: David Teigland <teigland@sourceware.org>
Date: Thu, 12 Aug 2021 20:53:07 +0000 (GMT)
Subject: main - toolcontext.h: use bit field in struct
Message-ID: <20210812205307.0CF4E3833003@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5c0562654b8449f91c423e92e9b78d4ce986dc3
Commit:        e5c0562654b8449f91c423e92e9b78d4ce986dc3
Parent:        59209ef04944e8f8fac2836be1d875a080c58a9e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 12 15:51:43 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 12 15:51:43 2021 -0500

toolcontext.h: use bit field in struct

Two recent additions should have used a bit instead
of an entire int.
---
 lib/commands/toolcontext.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0911b05f1..1a1785bfe 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -193,8 +193,8 @@ struct cmd_context {
 	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
 	unsigned sysinit:1;			/* --sysinit is used */
 	unsigned check_devs_used:1;		/* check devs used by LVs */
-	unsigned print_device_id_not_found;	/* print devices file entries not found */
-	unsigned ignore_device_name_mismatch;   /* skip updating devices file names */
+	unsigned print_device_id_not_found:1;	/* print devices file entries not found */
+	unsigned ignore_device_name_mismatch:1; /* skip updating devices file names */
 
 	/*
 	 * Devices and filtering.


