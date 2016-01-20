From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:54:03 +0000 (UTC)
Subject: master - cleanup: reformat sentence about max sizes
Message-ID: <20160120125403.13CB360D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21028a7903a8ef78e3dbda6afbd245c1cae1aae8
Commit:        21028a7903a8ef78e3dbda6afbd245c1cae1aae8
Parent:        7b5a8f61a79c88e9a99f3cec590163a143e70237
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 19 16:07:39 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: reformat sentence about max sizes

The extent size must fits all blocks in 4294967295 sectors
(in 512b units) this is 1/2 KiB less then 2TiB.

So while previous statement 'suggested' 2TiB is still acceptable value,
make it clear it's not.

As now we support any multiples of 128KB as extent size -
values like 2047G will still 'flow-in' otherwise the largest power-of-2
supported value is 1TiB.

With 1TiB user needs 8388608 extents for 8EiB device.
(FYI such device is already unusable with todays glibc-2.22.90-27)

4GiB extent size is currently the smallest extent size which allows
a user to create 8EiB devices (with 2GiB  it's less then 8EiB).

TODO: lvm2 may possibly print amount of 'lost/unused space' on a PV,
since using such ridiculously sized extent size may result in huge
space being left unaccessible.
---
 lib/metadata/metadata.c |    2 +-
 tools/toollib.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0336d5d..a795490 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1093,7 +1093,7 @@ uint32_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 
 	if (size > (uint64_t) MAX_EXTENT_COUNT * extent_size) {
 		log_error("Volume too large (%s) for extent size %s. "
-			  "Upper limit is %s.",
+			  "Upper limit is less then %s.",
 			  display_size(cmd, size),
 			  display_size(cmd, (uint64_t) extent_size),
 			  display_size(cmd, (uint64_t) MAX_EXTENT_COUNT *
diff --git a/tools/toollib.c b/tools/toollib.c
index dec9106..f2be8cb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -777,7 +777,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	}
 
 	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
-		log_error("Physical extent size cannot be larger than %s.",
+		log_error("Physical extent size must be smaller than %s.",
 				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
 		return 0;
 	}


