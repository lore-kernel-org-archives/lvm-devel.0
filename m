From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Wed, 7 Aug 2019 15:19:00 +0530
Subject: [PATCH] lib/metadata: Remove redundant warning when a pool is created
Message-ID: <CAMNNMLFYDCkr0Ur65qf4Q7A7Ogs=ijdiFsjerRy5WqrYZKU+HQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Redundant warnings when pool+thinlv is created in one step. Fixed.

Signed-off-by: Nikhil Kshirsagar <nkshirsa@redhat.com>
---
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index b9c01ee..ed5868c 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -369,10 +369,8 @@ int pool_check_overprovisioning(const struct
logical_volume *lv)
                         more_pools ? "s" : display_lvname(pool_lv),
                         txt,
                         (sz > 0) ? display_size(cmd, sz) : "no free
space in volume group");
-               if (max_threshold > 99 || !min_percent)
+               if (max_threshold > 99 )
                        log_print_unless_silent("WARNING: You have not
turned on protection against thin pools running out of space.");
-               if (max_threshold > 99)
-                       log_print_unless_silent("WARNING: Set
activation/thin_pool_autoextend_threshold below 100 to trigger
automatic extension of thin pools before they get full.");
                if (!min_percent)
                        log_print_unless_silent("WARNING: Set
activation/thin_pool_autoextend_percent above 0 to specify by how much
to extend thin pools reaching the threshold.");
                /* FIXME Also warn if there isn't sufficient free
space for one pool extension to occur? */
---


