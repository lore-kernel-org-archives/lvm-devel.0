From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:34 +0000 (GMT)
Subject: main - man: update lvmcache cache setting
Message-ID: <20230213133134.EDB673858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02fdb2480e8ec1d7b3da14e620295d0f93bff52a
Commit:        02fdb2480e8ec1d7b3da14e620295d0f93bff52a
Parent:        31076942f10bdd2ef449697c1a315372b71ee8c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 20:32:45 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

man: update lvmcache cache setting

Correct setting of migration_threshold and add clarify
how the user can restore default cache settings for cache policies.
Also document mq aliasing with smq for newer kernels.
---
 man/lvmcache.7_main | 28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 965e1cbdd..3beb8dea4 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -501,7 +501,18 @@ Checking migration threshold (in sectors) of running cached LV:
 .br
 .B lvs -o+kernel_cache_settings VG/LV
 .
-.SS dm-cache migration threshold
+.SS dm-cache cache settings
+.
+To set dm-cache cache setting use:
+.P
+--cachesettings 'option1=N option2=N ...'
+.P
+To unset/drop cache setting and restore its default kernel value
+use special keyword 'default' as option parameter:
+.P
+--cachesettings 'option1=default option2=default ...'
+.
+.SS dm-cache migration threshold cache setting
 .
 Migrating data between the origin and cache LV uses bandwidth.
 The user can set a throttle to prevent more than a certain amount of
@@ -510,17 +521,22 @@ account of normal io traffic going to the devices.
 .P
 User can set migration threshold via cache policy settings as
 "migration_threshold=<#sectors>" to set the maximum number
-of sectors being migrated, the default being 2048 sectors (1 MiB).
+of sectors being migrated, the default being 2048 sectors (1 MiB)
+or 8 cache chunks whichever of those two values is larger.
 .P
 Command to set migration threshold to 2 MiB (4096 sectors):
 .P
-.B lvcreate --cachepolicy 'migration_threshold=4096' VG/LV
+.B lvcreate --cachesettings 'migration_threshold=4096' VG/LV
 .P
 Command to display the migration threshold:
 .P
 .B lvs -o+kernel_cache_settings,cache_settings VG/LV
 .br
 .B lvs -o+chunksize VG/LV
+.P
+Command to restore/revert to default value:
+.P
+.B lvchange --cachesettings 'migration_threshold=default' VG/LV
 .
 .SS dm-cache cache policy
 .
@@ -533,6 +549,11 @@ back (flush) all cached writes to the origin LV.
 The older "mq" policy has a number of tunable parameters. The defaults are
 chosen to be suitable for the majority of systems, but in special
 circumstances, changing the settings can improve performance.
+Newer kernels however alias this policy with "smq" policy. Cache settings
+used to configure "mq" policy [random_threshold, sequential_threshold,
+discard_promote_adjustment, read_promote_adjustment,
+write_promote_adjustment] are thus silently ignored also performance
+matches "smq".
 .P
 With the --cachepolicy and --cachesettings options, the cache policy and
 settings can be set when caching is started, or changed on an existing
@@ -582,7 +603,6 @@ cache_settings {
 smq {
 .RS
 migration_threshold=8192
-random_threshold=4096
 .RE
 }
 .RE

