From: Milan Broz <mbroz@redhat.com>
Date: Thu,  9 Jun 2011 16:30:31 +0200
Subject: [PATCH 4/4] Fix dmsetup table output (different format in 2.02.85)
In-Reply-To: <1307629831-13816-1-git-send-email-mbroz@redhat.com>
References: <1307629831-13816-1-git-send-email-mbroz@redhat.com>
Message-ID: <1307629831-13816-4-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In previous versions < 2.02.85 dmsetup table <dev>
produced just dmsetup table, no device.

# dmsetup table abc
0 100 zero

Now is the output changed to:
# dmsetup table abc
abc: 0 100 zero

It should be only for all and multiple devices, not for one.

It breaks at least cryptsetup test suite, I guess there
are more problems.

Patch somehow workarounds it, I have no idea what was the intention
for this change.
I guess even Alasdair should use patch review process sometimes :-p

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-covercmd.sh |    5 +++++
 tools/dmsetup.c    |    9 ++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/test/t-covercmd.sh b/test/t-covercmd.sh
index 7843798..8c86388 100755
--- a/test/t-covercmd.sh
+++ b/test/t-covercmd.sh
@@ -34,6 +34,11 @@ pvcreate --norestorefile -u $TEST_UUID --metadatacopies 0 $dev5
 vgcreate -c n $vg $(cat DEVICES)
 lvcreate -n $lv -l 5 -i5 -I256 $vg
 
+# dmsetup table works
+dmsetup table "$vg-$lv"
+test $(dmsetup table "$vg-$lv" | cut -d' '  -f 3) = "striped"
+test $(dmsetup table "$vg-$lv" "$vg-$lv" | head -n 1 | cut -d:  -f 1) = "$vg-$lv"
+
 # test *scan and *display tools
 pvscan
 vgscan
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2a8e5a6..0a2e429 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1310,7 +1310,7 @@ static int _process_all(const struct command *cmd, int argc, char **argv, int si
 
 	do {
 		names = (struct dm_names *)((char *) names + next);
-		if (!fn(cmd, argc, argv, names, 1))
+		if (!fn(cmd, argc, argv, names, 2))
 			r = 0;
 		next = names->next;
 	} while (next);
@@ -1590,7 +1590,7 @@ static int _status(CMD_ARGS)
 			   _switches[VERBOSE_ARG]) {
 			if (!matched && _switches[VERBOSE_ARG])
 				_display_info(dmt);
-			if (multiple_devices && !_switches[VERBOSE_ARG])
+			if (multiple_devices > 1 && !_switches[VERBOSE_ARG])
 				printf("%s: ", name);
 			if (target_type) {
 				/* Suppress encryption key */
@@ -3412,7 +3412,10 @@ int main(int argc, char **argv)
 	#endif
 
       doit:
-	multiple_devices = (argc > 1);
+	if (argc > 1)
+		multiple_devices = (argc > 2) ? 2 : 1;
+	else
+		multiple_devices = 0;
 	do {
 		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");
-- 
1.7.5.3


