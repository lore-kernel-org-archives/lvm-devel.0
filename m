From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:58 +0000 (GMT)
Subject: main - cov: drop unneeded constness
Message-ID: <20230609160158.0F60C3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d648380484ecf58c33f92a84950bb0bf39424ef
Commit:        4d648380484ecf58c33f92a84950bb0bf39424ef
Parent:        17ee5df8576acf628d88fd6840ce55aa1388d6d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 11 19:17:18 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

cov: drop unneeded constness

If we want to have const structure - use a const pointer to avoid,
however making individual members const make it only assingle
in construct time and we already violate this logic since
we memcpy into the structure -  so drop these unnecessary consts...
---
 daemons/lvmpolld/lvmpolld-data-utils.h | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-data-utils.h b/daemons/lvmpolld/lvmpolld-data-utils.h
index 96a27f1c8..eeae4137c 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.h
+++ b/daemons/lvmpolld/lvmpolld-data-utils.h
@@ -45,18 +45,18 @@ struct lvmpolld_lv {
 	 * accessing following vars doesn't
 	 * require struct lvmpolld_lv lock
 	 */
-	struct lvmpolld_state *const ls;
+	struct lvmpolld_state *ls;
 	const enum poll_type type;
-	const char *const lvid;
-	const char *const lvmpolld_id;
-	const char *const devicesfile;
-	const char *const lvname; /* full vg/lv name */
+	const char *lvid;
+	const char *lvmpolld_id;
+	const char *devicesfile;
+	const char *lvname; /* full vg/lv name */
 	const unsigned pdtimeout; /* in seconds */
-	const char *const sinterval;
-	const char *const lvm_system_dir_env;
-	struct lvmpolld_store *const pdst;
-	const char *const *cmdargv;
-	const char *const *cmdenvp;
+	const char *sinterval;
+	const char *lvm_system_dir_env;
+	struct lvmpolld_store *pdst;
+	const char **cmdargv;
+	const char **cmdenvp;
 
 	/* only used by write */
 	pid_t cmd_pid;

