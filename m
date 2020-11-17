From: David Teigland <teigland@sourceware.org>
Date: Tue, 17 Nov 2020 17:21:01 +0000 (GMT)
Subject: main - lvm.conf: remove reference to locking_type
Message-ID: <20201117172101.1D69E386F005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b68141a49d94db7fa98beb345bc5a583d874e9e7
Commit:        b68141a49d94db7fa98beb345bc5a583d874e9e7
Parent:        9c0253d930103c33784fac5b303da20104a314b6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 11:19:55 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 11:19:55 2020 -0600

lvm.conf: remove reference to locking_type

---
 lib/config/config_settings.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e4e3dcdde..163e01485 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -982,8 +982,7 @@ cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECT
 	"a volume group's metadata, instead of always granting the read-only\n"
 	"requests immediately, delay them to allow the read-write requests to\n"
 	"be serviced. Without this setting, write access may be stalled by a\n"
-	"high volume of read-only requests. This option only affects\n"
-	"locking_type 1 viz. local file-based locking.\n")
+	"high volume of read-only requests. This option only affects file locks.\n")
 
 cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Search this directory first for shared libraries.\n")


