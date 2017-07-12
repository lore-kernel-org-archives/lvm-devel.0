From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Jul 2017 14:00:52 -0400
Subject: master - docs: Refresh kernel target docs
Message-ID: <201707121800.v6CI0qFa031375@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2de4b9747fcaf4c3735dc68318a28c80a939374
Commit:        c2de4b9747fcaf4c3735dc68318a28c80a939374
Parent:        c838e79cd2e1dc3c6054e661e6a2f65c0d5c6144
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 12 18:59:07 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 12 18:59:52 2017 +0100

docs: Refresh kernel target docs

---
 doc/kernel/cache.txt      |    6 +-
 doc/kernel/crypt.txt      |   80 +++++++++++++++++--
 doc/kernel/delay.txt      |    4 +-
 doc/kernel/flakey.txt     |    2 +-
 doc/kernel/integrity.txt  |  199 +++++++++++++++++++++++++++++++++++++++++++++
 doc/kernel/linear.txt     |    8 +-
 doc/kernel/log-writes.txt |   10 +-
 doc/kernel/raid.txt       |   92 ++++++++++++++++++++-
 doc/kernel/striped.txt    |    4 +-
 doc/kernel/switch.txt     |    2 +-
 doc/kernel/zoned.txt      |  144 ++++++++++++++++++++++++++++++++
 11 files changed, 525 insertions(+), 26 deletions(-)

diff --git a/doc/kernel/cache.txt b/doc/kernel/cache.txt
index 785eab8..cdfd0fe 100644
--- a/doc/kernel/cache.txt
+++ b/doc/kernel/cache.txt
@@ -207,6 +207,10 @@ Optional feature arguments are:
 		   block, then the cache block is invalidated.
 		   To enable passthrough mode the cache must be clean.
 
+   metadata2	: use version 2 of the metadata.  This stores the dirty bits
+                  in a separate btree, which improves speed of shutting
+		  down the cache.
+
 A policy called 'default' is always registered.  This is an alias for
 the policy we currently think is giving best all round performance.
 
@@ -286,7 +290,7 @@ message, which takes an arbitrary number of cblock ranges.  Each cblock
 range's end value is "one past the end", meaning 5-10 expresses a range
 of values from 5 to 9.  Each cblock must be expressed as a decimal
 value, in the future a variant message that takes cblock ranges
-expressed in hexidecimal may be needed to better support efficient
+expressed in hexadecimal may be needed to better support efficient
 invalidation of larger caches.  The cache must be in passthrough mode
 when invalidate_cblocks is used.
 
diff --git a/doc/kernel/crypt.txt b/doc/kernel/crypt.txt
index 692171f..3b3e1de 100644
--- a/doc/kernel/crypt.txt
+++ b/doc/kernel/crypt.txt
@@ -11,23 +11,57 @@ Parameters: <cipher> <key> <iv_offset> <device path> \
 	      <offset> [<#opt_params> <opt_params>]
 
 <cipher>
-    Encryption cipher and an optional IV generation mode.
-    (In format cipher[:keycount]-chainmode-ivmode[:ivopts]).
+    Encryption cipher, encryption mode and Initial Vector (IV) generator.
+
+    The cipher specifications format is:
+       cipher[:keycount]-chainmode-ivmode[:ivopts]
     Examples:
-       des
        aes-cbc-essiv:sha256
-       twofish-ecb
+       aes-xts-plain64
+       serpent-xts-plain64
+
+    Cipher format also supports direct specification with kernel crypt API
+    format (selected by capi: prefix). The IV specification is the same
+    as for the first format type.
+    This format is mainly used for specification of authenticated modes.
 
-    /proc/crypto contains supported crypto modes
+    The crypto API cipher specifications format is:
+        capi:cipher_api_spec-ivmode[:ivopts]
+    Examples:
+        capi:cbc(aes)-essiv:sha256
+        capi:xts(aes)-plain64
+    Examples of authenticated modes:
+        capi:gcm(aes)-random
+        capi:authenc(hmac(sha256),xts(aes))-random
+        capi:rfc7539(chacha20,poly1305)-random
+
+    The /proc/crypto contains a list of curently loaded crypto modes.
 
 <key>
-    Key used for encryption. It is encoded as a hexadecimal number.
+    Key used for encryption. It is encoded either as a hexadecimal number
+    or it can be passed as <key_string> prefixed with single colon
+    character (':') for keys residing in kernel keyring service.
     You can only use key sizes that are valid for the selected cipher
     in combination with the selected iv mode.
     Note that for some iv modes the key string can contain additional
     keys (for example IV seed) so the key contains more parts concatenated
     into a single string.
 
+<key_string>
+    The kernel keyring key is identified by string in following format:
+    <key_size>:<key_type>:<key_description>.
+
+<key_size>
+    The encryption key size in bytes. The kernel key payload size must match
+    the value passed in <key_size>.
+
+<key_type>
+    Either 'logon' or 'user' kernel key type.
+
+<key_description>
+    The kernel keyring key description crypt target should look for
+    when loading key of <key_type>.
+
 <keycount>
     Multi-key compatibility mode. You can define <keycount> keys and
     then sectors are encrypted according to their offsets (sector 0 uses key0;
@@ -76,6 +110,32 @@ submit_from_crypt_cpus
     thread because it benefits CFQ to have writes submitted using the
     same context.
 
+integrity:<bytes>:<type>
+    The device requires additional <bytes> metadata per-sector stored
+    in per-bio integrity structure. This metadata must by provided
+    by underlying dm-integrity target.
+
+    The <type> can be "none" if metadata is used only for persistent IV.
+
+    For Authenticated Encryption with Additional Data (AEAD)
+    the <type> is "aead". An AEAD mode additionally calculates and verifies
+    integrity for the encrypted device. The additional space is then
+    used for storing authentication tag (and persistent IV if needed).
+
+sector_size:<bytes>
+    Use <bytes> as the encryption unit instead of 512 bytes sectors.
+    This option can be in range 512 - 4096 bytes and must be power of two.
+    Virtual device will announce this size as a minimal IO and logical sector.
+
+iv_large_sectors
+   IV generators will use sector number counted in <sector_size> units
+   instead of default 512 bytes sectors.
+
+   For example, if <sector_size> is 4096 bytes, plain64 IV for the second
+   sector will be 8 (without flag) and 1 if iv_large_sectors is present.
+   The <iv_offset> must be multiple of <sector_size> (in 512 bytes units)
+   if this flag is specified.
+
 Example scripts
 ===============
 LUKS (Linux Unified Key Setup) is now the preferred way to set up disk
@@ -85,7 +145,13 @@ https://gitlab.com/cryptsetup/cryptsetup
 [[
 #!/bin/sh
 # Create a crypt device using dmsetup
-dmsetup create crypt1 --table "0 `blockdev --getsize $1` crypt aes-cbc-essiv:sha256 babebabebabebabebabebabebabebabe 0 $1 0"
+dmsetup create crypt1 --table "0 `blockdev --getsz $1` crypt aes-cbc-essiv:sha256 babebabebabebabebabebabebabebabe 0 $1 0"
+]]
+
+[[
+#!/bin/sh
+# Create a crypt device using dmsetup when encryption key is stored in keyring service
+dmsetup create crypt2 --table "0 `blockdev --getsize $1` crypt aes-cbc-essiv:sha256 :32:logon:my_prefix:my_key 0 $1 0"
 ]]
 
 [[
diff --git a/doc/kernel/delay.txt b/doc/kernel/delay.txt
index a07b592..4b1d22a 100644
--- a/doc/kernel/delay.txt
+++ b/doc/kernel/delay.txt
@@ -16,12 +16,12 @@ Example scripts
 [[
 #!/bin/sh
 # Create device delaying rw operation for 500ms
-echo "0 `blockdev --getsize $1` delay $1 0 500" | dmsetup create delayed
+echo "0 `blockdev --getsz $1` delay $1 0 500" | dmsetup create delayed
 ]]
 
 [[
 #!/bin/sh
 # Create device delaying only write operation for 500ms and
 # splitting reads and writes to different devices $1 $2
-echo "0 `blockdev --getsize $1` delay $1 0 0 $2 0 500" | dmsetup create delayed
+echo "0 `blockdev --getsz $1` delay $1 0 0 $2 0 500" | dmsetup create delayed
 ]]
diff --git a/doc/kernel/flakey.txt b/doc/kernel/flakey.txt
index 6ff5c23..c430307 100644
--- a/doc/kernel/flakey.txt
+++ b/doc/kernel/flakey.txt
@@ -42,7 +42,7 @@ Optional feature parameters:
     <direction>: Either 'r' to corrupt reads or 'w' to corrupt writes.
 		 'w' is incompatible with drop_writes.
     <value>: The value (from 0-255) to write.
-    <flags>: Perform the replacement only if bio->bi_rw has all the
+    <flags>: Perform the replacement only if bio->bi_opf has all the
 	     selected flags set.
 
 Examples:
diff --git a/doc/kernel/integrity.txt b/doc/kernel/integrity.txt
new file mode 100644
index 0000000..f33e3ad
--- /dev/null
+++ b/doc/kernel/integrity.txt
@@ -0,0 +1,199 @@
+The dm-integrity target emulates a block device that has additional
+per-sector tags that can be used for storing integrity information.
+
+A general problem with storing integrity tags with every sector is that
+writing the sector and the integrity tag must be atomic - i.e. in case of
+crash, either both sector and integrity tag or none of them is written.
+
+To guarantee write atomicity, the dm-integrity target uses journal, it
+writes sector data and integrity tags into a journal, commits the journal
+and then copies the data and integrity tags to their respective location.
+
+The dm-integrity target can be used with the dm-crypt target - in this
+situation the dm-crypt target creates the integrity data and passes them
+to the dm-integrity target via bio_integrity_payload attached to the bio.
+In this mode, the dm-crypt and dm-integrity targets provide authenticated
+disk encryption - if the attacker modifies the encrypted device, an I/O
+error is returned instead of random data.
+
+The dm-integrity target can also be used as a standalone target, in this
+mode it calculates and verifies the integrity tag internally. In this
+mode, the dm-integrity target can be used to detect silent data
+corruption on the disk or in the I/O path.
+
+
+When loading the target for the first time, the kernel driver will format
+the device. But it will only format the device if the superblock contains
+zeroes. If the superblock is neither valid nor zeroed, the dm-integrity
+target can't be loaded.
+
+To use the target for the first time:
+1. overwrite the superblock with zeroes
+2. load the dm-integrity target with one-sector size, the kernel driver
+	will format the device
+3. unload the dm-integrity target
+4. read the "provided_data_sectors" value from the superblock
+5. load the dm-integrity target with the the target size
+	"provided_data_sectors"
+6. if you want to use dm-integrity with dm-crypt, load the dm-crypt target
+	with the size "provided_data_sectors"
+
+
+Target arguments:
+
+1. the underlying block device
+
+2. the number of reserved sector at the beginning of the device - the
+	dm-integrity won't read of write these sectors
+
+3. the size of the integrity tag (if "-" is used, the size is taken from
+	the internal-hash algorithm)
+
+4. mode:
+	D - direct writes (without journal) - in this mode, journaling is
+		not used and data sectors and integrity tags are written
+		separately. In case of crash, it is possible that the data
+		and integrity tag doesn't match.
+	J - journaled writes - data and integrity tags are written to the
+		journal and atomicity is guaranteed. In case of crash,
+		either both data and tag or none of them are written. The
+		journaled mode degrades write throughput twice because the
+		data have to be written twice.
+	R - recovery mode - in this mode, journal is not replayed,
+		checksums are not checked and writes to the device are not
+		allowed. This mode is useful for data recovery if the
+		device cannot be activated in any of the other standard
+		modes.
+
+5. the number of additional arguments
+
+Additional arguments:
+
+journal_sectors:number
+	The size of journal, this argument is used only if formatting the
+	device. If the device is already formatted, the value from the
+	superblock is used.
+
+interleave_sectors:number
+	The number of interleaved sectors. This values is rounded down to
+	a power of two. If the device is already formatted, the value from
+	the superblock is used.
+
+buffer_sectors:number
+	The number of sectors in one buffer. The value is rounded down to
+	a power of two.
+
+	The tag area is accessed using buffers, the buffer size is
+	configurable. The large buffer size means that the I/O size will
+	be larger, but there could be less I/Os issued.
+
+journal_watermark:number
+	The journal watermark in percents. When the size of the journal
+	exceeds this watermark, the thread that flushes the journal will
+	be started.
+
+commit_time:number
+	Commit time in milliseconds. When this time passes, the journal is
+	written. The journal is also written immediatelly if the FLUSH
+	request is received.
+
+internal_hash:algorithm(:key)	(the key is optional)
+	Use internal hash or crc.
+	When this argument is used, the dm-integrity target won't accept
+	integrity tags from the upper target, but it will automatically
+	generate and verify the integrity tags.
+
+	You can use a crc algorithm (such as crc32), then integrity target
+	will protect the data against accidental corruption.
+	You can also use a hmac algorithm (for example
+	"hmac(sha256):0123456789abcdef"), in this mode it will provide
+	cryptographic authentication of the data without encryption.
+
+	When this argument is not used, the integrity tags are accepted
+	from an upper layer target, such as dm-crypt. The upper layer
+	target should check the validity of the integrity tags.
+
+journal_crypt:algorithm(:key)	(the key is optional)
+	Encrypt the journal using given algorithm to make sure that the
+	attacker can't read the journal. You can use a block cipher here
+	(such as "cbc(aes)") or a stream cipher (for example "chacha20",
+	"salsa20", "ctr(aes)" or "ecb(arc4)").
+
+	The journal contains history of last writes to the block device,
+	an attacker reading the journal could see the last sector nubmers
+	that were written. From the sector numbers, the attacker can infer
+	the size of files that were written. To protect against this
+	situation, you can encrypt the journal.
+
+journal_mac:algorithm(:key)	(the key is optional)
+	Protect sector numbers in the journal from accidental or malicious
+	modification. To protect against accidental modification, use a
+	crc algorithm, to protect against malicious modification, use a
+	hmac algorithm with a key.
+
+	This option is not needed when using internal-hash because in this
+	mode, the integrity of journal entries is checked when replaying
+	the journal. Thus, modified sector number would be detected at
+	this stage.
+
+block_size:number
+	The size of a data block in bytes.  The larger the block size the
+	less overhead there is for per-block integrity metadata.
+	Supported values are 512, 1024, 2048 and 4096 bytes.  If not
+	specified the default block size is 512 bytes.
+
+The journal mode (D/J), buffer_sectors, journal_watermark, commit_time can
+be changed when reloading the target (load an inactive table and swap the
+tables with suspend and resume). The other arguments should not be changed
+when reloading the target because the layout of disk data depend on them
+and the reloaded target would be non-functional.
+
+
+The layout of the formatted block device:
+* reserved sectors (they are not used by this target, they can be used for
+  storing LUKS metadata or for other purpose), the size of the reserved
+  area is specified in the target arguments
+* superblock (4kiB)
+	* magic string - identifies that the device was formatted
+	* version
+	* log2(interleave sectors)
+	* integrity tag size
+	* the number of journal sections
+	* provided data sectors - the number of sectors that this target
+	  provides (i.e. the size of the device minus the size of all
+	  metadata and padding). The user of this target should not send
+	  bios that access data beyond the "provided data sectors" limit.
+	* flags - a flag is set if journal_mac is used
+* journal
+	The journal is divided into sections, each section contains:
+	* metadata area (4kiB), it contains journal entries
+	  every journal entry contains:
+		* logical sector (specifies where the data and tag should
+		  be written)
+		* last 8 bytes of data
+		* integrity tag (the size is specified in the superblock)
+	    every metadata sector ends with
+		* mac (8-bytes), all the macs in 8 metadata sectors form a
+		  64-byte value. It is used to store hmac of sector
+		  numbers in the journal section, to protect against a
+		  possibility that the attacker tampers with sector
+		  numbers in the journal.
+		* commit id
+	* data area (the size is variable; it depends on how many journal
+	  entries fit into the metadata area)
+	    every sector in the data area contains:
+		* data (504 bytes of data, the last 8 bytes are stored in
+		  the journal entry)
+		* commit id
+	To test if the whole journal section was written correctly, every
+	512-byte sector of the journal ends with 8-byte commit id. If the
+	commit id matches on all sectors in a journal section, then it is
+	assumed that the section was written correctly. If the commit id
+	doesn't match, the section was written partially and it should not
+	be replayed.
+* one or more runs of interleaved tags and data. Each run contains:
+	* tag area - it contains integrity tags. There is one tag for each
+	  sector in the data area
+	* data area - it contains data sectors. The number of data sectors
+	  in one run must be a power of two. log2 of this value is stored
+	  in the superblock.
diff --git a/doc/kernel/linear.txt b/doc/kernel/linear.txt
index d5307d3..7cb98d8 100644
--- a/doc/kernel/linear.txt
+++ b/doc/kernel/linear.txt
@@ -16,15 +16,15 @@ Example scripts
 [[
 #!/bin/sh
 # Create an identity mapping for a device
-echo "0 `blockdev --getsize $1` linear $1 0" | dmsetup create identity
+echo "0 `blockdev --getsz $1` linear $1 0" | dmsetup create identity
 ]]
 
 
 [[
 #!/bin/sh
 # Join 2 devices together
-size1=`blockdev --getsize $1`
-size2=`blockdev --getsize $2`
+size1=`blockdev --getsz $1`
+size2=`blockdev --getsz $2`
 echo "0 $size1 linear $1 0
 $size1 $size2 linear $2 0" | dmsetup create joined
 ]]
@@ -44,7 +44,7 @@ if (!defined($dev)) {
         die("Please specify a device.\n");
 }
 
-my $dev_size = `blockdev --getsize $dev`;
+my $dev_size = `blockdev --getsz $dev`;
 my $extents = int($dev_size / $extent_size) -
               (($dev_size % $extent_size) ? 1 : 0);
 
diff --git a/doc/kernel/log-writes.txt b/doc/kernel/log-writes.txt
index c10f30c..f4ebcba 100644
--- a/doc/kernel/log-writes.txt
+++ b/doc/kernel/log-writes.txt
@@ -14,14 +14,14 @@ Log Ordering
 
 We log things in order of completion once we are sure the write is no longer in
 cache.  This means that normal WRITE requests are not actually logged until the
-next REQ_FLUSH request.  This is to make it easier for userspace to replay the
-log in a way that correlates to what is on disk and not what is in cache, to
-make it easier to detect improper waiting/flushing.
+next REQ_PREFLUSH request.  This is to make it easier for userspace to replay
+the log in a way that correlates to what is on disk and not what is in cache,
+to make it easier to detect improper waiting/flushing.
 
 This works by attaching all WRITE requests to a list once the write completes.
-Once we see a REQ_FLUSH request we splice this list onto the request and once
+Once we see a REQ_PREFLUSH request we splice this list onto the request and once
 the FLUSH request completes we log all of the WRITEs and then the FLUSH.  Only
-completed WRITEs, at the time the REQ_FLUSH is issued, are added in order to
+completed WRITEs, at the time the REQ_PREFLUSH is issued, are added in order to
 simulate the worst case scenario with regard to power failures.  Consider the
 following example (W means write, C means complete):
 
diff --git a/doc/kernel/raid.txt b/doc/kernel/raid.txt
index df2d636..7e06e65 100644
--- a/doc/kernel/raid.txt
+++ b/doc/kernel/raid.txt
@@ -14,8 +14,12 @@ The target is named "raid" and it accepts the following parameters:
     <#raid_devs> <metadata_dev0> <dev0> [.. <metadata_devN> <devN>]
 
 <raid_type>:
+  raid0		RAID0 striping (no resilience)
   raid1		RAID1 mirroring
-  raid4		RAID4 dedicated parity disk
+  raid4		RAID4 with dedicated last parity disk
+  raid5_n 	RAID5 with dedicated last parity disk supporting takeover
+		Same as raid4
+		-Transitory layout
   raid5_la	RAID5 left asymmetric
 		- rotating parity 0 with data continuation
   raid5_ra	RAID5 right asymmetric
@@ -30,7 +34,19 @@ The target is named "raid" and it accepts the following parameters:
 		- rotating parity N (right-to-left) with data restart
   raid6_nc	RAID6 N continue
 		- rotating parity N (right-to-left) with data continuation
+  raid6_n_6	RAID6 with dedicate parity disks
+		- parity and Q-syndrome on the last 2 disks;
+		  layout for takeover from/to raid4/raid5_n
+  raid6_la_6	Same as "raid_la" plus dedicated last Q-syndrome disk
+		- layout for takeover from raid5_la from/to raid6
+  raid6_ra_6	Same as "raid5_ra" dedicated last Q-syndrome disk
+		- layout for takeover from raid5_ra from/to raid6
+  raid6_ls_6	Same as "raid5_ls" dedicated last Q-syndrome disk
+		- layout for takeover from raid5_ls from/to raid6
+  raid6_rs_6	Same as "raid5_rs" dedicated last Q-syndrome disk
+		- layout for takeover from raid5_rs from/to raid6
   raid10        Various RAID10 inspired algorithms chosen by additional params
+		(see raid10_format and raid10_copies below)
 		- RAID10: Striped Mirrors (aka 'Striping on top of mirrors')
 		- RAID1E: Integrated Adjacent Stripe Mirroring
 		- RAID1E: Integrated Offset Stripe Mirroring
@@ -116,10 +132,57 @@ The target is named "raid" and it accepts the following parameters:
 		Here we see layouts closely akin to 'RAID1E - Integrated
 		Offset Stripe Mirroring'.
 
+        [delta_disks <N>]
+		The delta_disks option value (-251 < N < +251) triggers
+		device removal (negative value) or device addition (positive
+		value) to any reshape supporting raid levels 4/5/6 and 10.
+		RAID levels 4/5/6 allow for addition of devices (metadata
+		and data device tuple), raid10_near and raid10_offset only
+		allow for device addition. raid10_far does not support any
+		reshaping@all.
+		A minimum of devices have to be kept to enforce resilience,
+		which is 3 devices for raid4/5 and 4 devices for raid6.
+
+        [data_offset <sectors>]
+		This option value defines the offset into each data device
+		where the data starts. This is used to provide out-of-place
+		reshaping space to avoid writing over data whilst
+		changing the layout of stripes, hence an interruption/crash
+		may happen at any time without the risk of losing data.
+		E.g. when adding devices to an existing raid set during
+		forward reshaping, the out-of-place space will be allocated
+		at the beginning of each raid device. The kernel raid4/5/6/10
+		MD personalities supporting such device addition will read the data from
+		the existing first stripes (those with smaller number of stripes)
+		starting at data_offset to fill up a new stripe with the larger
+		number of stripes, calculate the redundancy blocks (CRC/Q-syndrome)
+		and write that new stripe to offset 0. Same will be applied to all
+		N-1 other new stripes. This out-of-place scheme is used to change
+		the RAID type (i.e. the allocation algorithm) as well, e.g.
+		changing from raid5_ls to raid5_n.
+
+	[journal_dev <dev>]
+		This option adds a journal device to raid4/5/6 raid sets and
+		uses it to close the 'write hole' caused by the non-atomic updates
+		to the component devices which can cause data loss during recovery.
+		The journal device is used as writethrough thus causing writes to
+		be throttled versus non-journaled raid4/5/6 sets.
+		Takeover/reshape is not possible with a raid4/5/6 journal device;
+		it has to be deconfigured before requesting these.
+
+	[journal_mode <mode>]
+		This option sets the caching mode on journaled raid4/5/6 raid sets
+		(see 'journal_dev <dev>' above) to 'writethrough' or 'writeback'.
+		If 'writeback' is selected the journal device has to be resilient
+		and must not suffer from the 'write hole' problem itself (e.g. use
+		raid1 or raid10) to avoid a single point of failure.
+
 <#raid_devs>: The number of devices composing the array.
 	Each device consists of two entries.  The first is the device
 	containing the metadata (if any); the second is the one containing the
-	data.
+	data. A Maximum of 64 metadata/data device entries are supported
+	up to target version 1.8.0.
+	1.9.0 supports up to 253 which is enforced by the used MD kernel runtime.
 
 	If a drive has failed or is missing at creation time, a '-' can be
 	given for both the metadata and data drives for a given position.
@@ -195,6 +258,14 @@ recovery.  Here is a fuller description of the individual fields:
 			in RAID1/10 or wrong parity values found in RAID4/5/6.
 			This value is valid only after a "check" of the array
 			is performed.  A healthy array has a 'mismatch_cnt' of 0.
+	<data_offset>   The current data offset to the start of the user data on
+			each component device of a raid set (see the respective
+			raid parameter to support out-of-place reshaping).
+	<journal_char>	'A' - active write-through journal device.
+			'a' - active write-back journal device.
+			'D' - dead journal device.
+			'-' - no journal device.
+
 
 Message Interface
 -----------------
@@ -207,7 +278,6 @@ include:
 	"recover"- Initiate/continue a recover process.
 	"check"  - Initiate a check (i.e. a "scrub") of the array.
 	"repair" - Initiate a repair of the array.
-	"reshape"- Currently unsupported (-EINVAL).
 
 
 Discard Support
@@ -257,3 +327,19 @@ Version History
 1.5.2   'mismatch_cnt' is zero unless [last_]sync_action is "check".
 1.6.0   Add discard support (and devices_handle_discard_safely module param).
 1.7.0   Add support for MD RAID0 mappings.
+1.8.0   Explicitly check for compatible flags in the superblock metadata
+	and reject to start the raid set if any are set by a newer
+	target version, thus avoiding data corruption on a raid set
+	with a reshape in progress.
+1.9.0   Add support for RAID level takeover/reshape/region size
+	and set size reduction.
+1.9.1   Fix activation of existing RAID 4/10 mapped devices
+1.9.2   Don't emit '- -' on the status table line in case the constructor
+	fails reading a superblock. Correctly emit 'maj:min1 maj:min2' and
+	'D' on the status line.  If '- -' is passed into the constructor, emit
+	'- -' on the table line and '-' as the status line health character.
+1.10.0  Add support for raid4/5/6 journal device
+1.10.1  Fix data corruption on reshape request
+1.11.0  Fix table line argument order
+	(wrong raid10_copies/raid10_format sequence)
+1.11.1  Add raid4/5/6 journal write-back support via journal_mode option
diff --git a/doc/kernel/striped.txt b/doc/kernel/striped.txt
index 45f3b91..07ec492 100644
--- a/doc/kernel/striped.txt
+++ b/doc/kernel/striped.txt
@@ -37,9 +37,9 @@ if (!$num_devs) {
         die("Specify at least one device\n");
 }
 
-$min_dev_size = `blockdev --getsize $devs[0]`;
+$min_dev_size = `blockdev --getsz $devs[0]`;
 for ($i = 1; $i < $num_devs; $i++) {
-        my $this_size = `blockdev --getsize $devs[$i]`;
+        my $this_size = `blockdev --getsz $devs[$i]`;
         $min_dev_size = ($min_dev_size < $this_size) ?
                         $min_dev_size : $this_size;
 }
diff --git a/doc/kernel/switch.txt b/doc/kernel/switch.txt
index 424835e..5bd4831 100644
--- a/doc/kernel/switch.txt
+++ b/doc/kernel/switch.txt
@@ -123,7 +123,7 @@ Assume that you have volumes vg1/switch0 vg1/switch1 vg1/switch2 with
 the same size.
 
 Create a switch device with 64kB region size:
-    dmsetup create switch --table "0 `blockdev --getsize /dev/vg1/switch0`
+    dmsetup create switch --table "0 `blockdev --getsz /dev/vg1/switch0`
 	switch 3 128 0 /dev/vg1/switch0 0 /dev/vg1/switch1 0 /dev/vg1/switch2 0"
 
 Set mappings for the first 7 entries to point to devices switch0, switch1,
diff --git a/doc/kernel/zoned.txt b/doc/kernel/zoned.txt
new file mode 100644
index 0000000..736fcc7
--- /dev/null
+++ b/doc/kernel/zoned.txt
@@ -0,0 +1,144 @@
+dm-zoned
+========
+
+The dm-zoned device mapper target exposes a zoned block device (ZBC and
+ZAC compliant devices) as a regular block device without any write
+pattern constraints. In effect, it implements a drive-managed zoned
+block device which hides from the user (a file system or an application
+doing raw block device accesses) the sequential write constraints of
+host-managed zoned block devices and can mitigate the potential
+device-side performance degradation due to excessive random writes on
+host-aware zoned block devices.
+
+For a more detailed description of the zoned block device models and
+their constraints see (for SCSI devices):
+
+http://www.t10.org/drafts.htm#ZBC_Family
+
+and (for ATA devices):
+
+http://www.t13.org/Documents/UploadedDocuments/docs2015/di537r05-Zoned_Device_ATA_Command_Set_ZAC.pdf
+
+The dm-zoned implementation is simple and minimizes system overhead (CPU
+and memory usage as well as storage capacity loss). For a 10TB
+host-managed disk with 256 MB zones, dm-zoned memory usage per disk
+instance is@most 4.5 MB and as little as 5 zones will be used
+internally for storing metadata and performaing reclaim operations.
+
+dm-zoned target devices are formatted and checked using the dmzadm
+utility available at:
+
+https://github.com/hgst/dm-zoned-tools
+
+Algorithm
+=========
+
+dm-zoned implements an on-disk buffering scheme to handle non-sequential
+write accesses to the sequential zones of a zoned block device.
+Conventional zones are used for caching as well as for storing internal
+metadata.
+
+The zones of the device are separated into 2 types:
+
+1) Metadata zones: these are conventional zones used to store metadata.
+Metadata zones are not reported as useable capacity to the user.
+
+2) Data zones: all remaining zones, the vast majority of which will be
+sequential zones used exclusively to store user data. The conventional
+zones of the device may be used also for buffering user random writes.
+Data in these zones may be directly mapped to the conventional zone, but
+later moved to a sequential zone so that the conventional zone can be
+reused for buffering incoming random writes.
+
+dm-zoned exposes a logical device with a sector size of 4096 bytes,
+irrespective of the physical sector size of the backend zoned block
+device being used. This allows reducing the amount of metadata needed to
+manage valid blocks (blocks written).
+
+The on-disk metadata format is as follows:
+
+1) The first block of the first conventional zone found contains the
+super block which describes the on disk amount and position of metadata
+blocks.
+
+2) Following the super block, a set of blocks is used to describe the
+mapping of the logical device blocks. The mapping is done per chunk of
+blocks, with the chunk size equal to the zoned block device size. The
+mapping table is indexed by chunk number and each mapping entry
+indicates the zone number of the device storing the chunk of data. Each
+mapping entry may also indicate if the zone number of a conventional
+zone used to buffer random modification to the data zone.
+
+3) A set of blocks used to store bitmaps indicating the validity of
+blocks in the data zones follows the mapping table. A valid block is
+defined as a block that was written and not discarded. For a buffered
+data chunk, a block is always valid only in the data zone mapping the
+chunk or in the buffer zone of the chunk.
+
+For a logical chunk mapped to a conventional zone, all write operations
+are processed by directly writing to the zone. If the mapping zone is a
+sequential zone, the write operation is processed directly only if the
+write offset within the logical chunk is equal to the write pointer
+offset within of the sequential data zone (i.e. the write operation is
+aligned on the zone write pointer). Otherwise, write operations are
+processed indirectly using a buffer zone. In that case, an unused
+conventional zone is allocated and assigned to the chunk being
+accessed. Writing a block to the buffer zone of a chunk will
+automatically invalidate the same block in the sequential zone mapping
+the chunk. If all blocks of the sequential zone become invalid, the zone
+is freed and the chunk buffer zone becomes the primary zone mapping the
+chunk, resulting in native random write performance similar to a regular
+block device.
+
+Read operations are processed according to the block validity
+information provided by the bitmaps. Valid blocks are read either from
+the sequential zone mapping a chunk, or if the chunk is buffered, from
+the buffer zone assigned. If the accessed chunk has no mapping, or the
+accessed blocks are invalid, the read buffer is zeroed and the read
+operation terminated.
+
+After some time, the limited number of convnetional zones available may
+be exhausted (all used to map chunks or buffer sequential zones) and
+unaligned writes to unbuffered chunks become impossible. To avoid this
+situation, a reclaim process regularly scans used conventional zones and
+tries to reclaim the least recently used zones by copying the valid
+blocks of the buffer zone to a free sequential zone. Once the copy
+completes, the chunk mapping is updated to point to the sequential zone
+and the buffer zone freed for reuse.
+
+Metadata Protection
+===================
+
+To protect metadata against corruption in case of sudden power loss or
+system crash, 2 sets of metadata zones are used. One set, the primary
+set, is used as the main metadata region, while the secondary set is
+used as a staging area. Modified metadata is first written to the
+secondary set and validated by updating the super block in the secondary
+set, a generation counter is used to indicate that this set contains the
+newest metadata. Once this operation completes, in place of metadata
+block updates can be done in the primary metadata set. This ensures that
+one of the set is always consistent (all modifications committed or none
+at all). Flush operations are used as a commit point. Upon reception of
+a flush request, metadata modification activity is temporarily blocked
+(for both incoming BIO processing and reclaim process) and all dirty
+metadata blocks are staged and updated. Normal operation is then
+resumed. Flushing metadata thus only temporarily delays write and
+discard requests. Read requests can be processed concurrently while
+metadata flush is being executed.
+
+Usage
+=====
+
+A zoned block device must first be formatted using the dmzadm tool. This
+will analyze the device zone configuration, determine where to place the
+metadata sets on the device and initialize the metadata sets.
+
+Ex:
+
+dmzadm --format /dev/sdxx
+
+For a formatted device, the target can be created normally with the
+dmsetup utility. The only parameter that dm-zoned requires is the
+underlying zoned block device name. Ex:
+
+echo "0 `blockdev --getsize ${dev}` zoned ${dev}" | dmsetup create dmz-`basename ${dev}`


