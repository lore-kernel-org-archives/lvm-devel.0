From: Milan Broz <mbroz@redhat.com>
Date: Wed, 21 Jan 2009 12:19:41 +0100
Subject: [PATCH 00/15][RFC] Encrypted logical volumes for LVM2
Message-ID: <cover.1232488181.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch series implements encrypted volume handling in LVM2.

Not all functions are finished but it should provide basic
design overview for review and discussion.

(I know that patches are big, but I see no better alternative
for posting...)

Milan

Basic idea is provide standard encrypted volume management in LVM2
but keep key management (and userspace crypto handling) outside lvm core.

Then we can support simple key management (equivalent to
cryptsetup/luks) but also library for connecting to some
infrastructure. The metadata format is still the same.

This patches implements these subsystems, needed for
correct operation:
(see particular patches for description, this is just short overview)

	- new "crypt" and "crypt-keystore" lv segments
	(crypt is equivalent to linear segment, just with
	encrypted areas, crypt-keystore is area which
	include special metadata interpreted by particular
	driver - e.g. LUKS metadata area)

	- key handlers interface, for now
		"simple" handler
		"luks1" handler

	- internal master key cache (lvm need temporarily store
	master key used in dm-crypt maping table for various
	mapping table operations)
	
	- encrypted LVs & cryptostore LVs manipulation code
	
	- lvcreate support, lvconvert to allow importing
	already prepared encrypted volumes

	- some helper functions (like password entry etc.)
	(is linking to other library worth to replace these?)

Key management inside lvm

For manipulating with volume inside kernel device-mapper, lvm needs
to know master key and cipher parameters.

Crypt store says which method (crytpto store type) is used to obtain
these attributes, key handler implement these methods
(resp. should provide interface to proper tools for key management).

Examples of Key handlers:

  - The simple one is "plain" handler, where the used cipher is stored
in LVM metadata directly and driver asks user for master key.

 - Second one (not yet implemented) is "hashed" where the key is
hashed value of user entered password.
(equivalent of crypsetup in non-luks mode).

 - More sophisticated is use some key management system, and simple
 example is support for "LUKS".
 (here equivalent of cryptsetup-luks keystore)
 
 - For enterprise segment, it need implement key handler which will
 communicate with an infrastructure to obtain encryption parameters and key.

 ...

So the key handlers should be separated from basic lvm core,
I expect that it should be dynamically loaded library [RFC].
(library loading is not yet implemented in patchset, but
code should be already separate modules)


Metadata representation:

 - everything new is in crypt and crypt-keystore segment, so
  even old code should read partial metadata properly,
  just ignoring these segments.

 - new "crypt" segment has the same format as linear,
   just it adds "crypto_store" attribute, which is name
   of special LV withing the VG.
   Only one area is allowed in this segment (the same like linear)
   (it uses "areas" instead of "stripes" in segment metadata)

 - special cryptostore LV containing "crypt-keystore" segment.
   Here is stored information how to obtian crypt attributes
   needed for encrypted LV activation

     - crypostore LV can be shared between encrypted segments

     - the special name "cryptostoreN" is now reserved

     - it defines some basic metadata atttributes
       (handler name, cipher, key_size, key_hash)
       which are retained (if present) even if particular key handler
       is not loaded.
       (Basically this concept allows manipulation with metadata 
       in some rescue mode, but without specialized key handlers loaded.)

 - encrypted LV can consist of several encrypted segments, In normal
   situation all segments will use the same cryptostore.
   But it should support  online reencryption in future (in this situation
   it temporary  uses different crypto stores for segments).

 - cryptostore LV is special, invisible LV with only crypt-keystore segments.
   To simplify code, if the last lv segment referencing this LV is removed,
   cryptostore LV is removed too.

Best to see a METADATA example:

 vg {	... # no change here
	logical_volumes {

		# simple encrypted volume
		tst {
			id = "ONqIFB-p2vX-rQ2V-B9Yg-0kPB-uKbh-NWIssL"
			status = ["READ", "WRITE", "VISIBLE"]
			flags = []
			segment_count = 1

			segment1 {
				start_extent = 0
				extent_count = 4        # 16 Megabytes

				type = "crypt"
				crypto_store = "cryptostore1"

				areas = [
					"pv2", 12
				]
			}
		}

		# imported LUKS1 volume
		luks1 {
			id = "G0NURa-cD93-6VnU-zHGP-Affz-Hu8Q-3MU1vt"
			status = ["READ", "WRITE", "VISIBLE"]
			flags = []
			segment_count = 1

			segment1 {
				start_extent = 0
				extent_count = 3        # 12 Megabytes

				type = "crypt"
				crypto_store = "cryptostore2"

				areas = [
					"pv0", 4
				]
			}
		}

		# plain cryptostore
		cryptostore1 {
			id = "5WYknM-Vhti-pGqU-yIN7-UgY1-I3KW-Hnmb08"
			status = ["READ"]
			flags = []
			allocation_policy = "normal"
			segment_count = 1

			segment1 {
				start_extent = 0
				extent_count = 0        # 0 Kilobytes

				type = "crypt-keystore"
				handler = "plain"
				cipher = "aes-xts-plain"
				key_size = 256  # 32 Bytes
			}
		}

		# LUKS1 cryptostore
		cryptostore2 {
			id = "qbo213-gxbu-NeI3-n63K-vnOT-JtNB-RXmOUk"
			status = ["READ"]
			flags = []
			allocation_policy = "normal"
			segment_count = 1

			segment1 {
				start_extent = 0
				extent_count = 1        # 4 Megabytes

				type = "crypt-keystore"
				handler = "luks1"

				# LUKS keyslots live here
				areas = [
					"pv0", 3
				]
			}
		}
	}
}


This is the (huge) patchset statistic :-)

Milan Broz (15):
  Support crypt segment in libdevmapper tree.
  Add lvm-crypto header file with basic crypto struct definintions:
  Add master key cache to LVM.
  Add simple password helpers.
  Add key store handlers machinery.
  Prepare source for recognising crypt segment.
  Add "crypt" and "crypt-keystore" segment implementation.
  Add crypto_store to LV segment allocation functions.
  Add encrypted LV manipulation functions.
  Cache key from crypt mapping table if segment is active.
  Add lvcreate crypto LV implementation.
  Add lvconcert crypt implementation.
  Add --keyfile option.
  Add *testing* LUKS1 keystore implementation.
  Add simple test for crypto volumes.

 configure                        |  131 ++++++++++-
 configure.in                     |   51 ++++
 include/.symlinks                |    1 +
 lib/Makefile.in                  |   14 +
 lib/activate/activate.c          |   47 ++++
 lib/activate/activate.h          |    5 +
 lib/activate/dev_manager.c       |   59 +++++
 lib/activate/dev_manager.h       |    4 +
 lib/commands/toolcontext.c       |   37 +++
 lib/crypt/crypt.c                |  372 ++++++++++++++++++++++++++++
 lib/crypt/key_handlers.c         |   88 +++++++
 lib/crypt/key_luks.c             |  495 ++++++++++++++++++++++++++++++++++++++
 lib/crypt/lvm-crypto.h           |  126 ++++++++++
 lib/crypt/masterkey.c            |  152 ++++++++++++
 lib/crypt/password.c             |  127 ++++++++++
 lib/crypt/pbkdf2.c               |  199 +++++++++++++++
 lib/crypt/pbkdf2.h               |   36 +++
 lib/format1/format1.c            |    1 +
 lib/format1/import-extents.c     |    4 +-
 lib/format_pool/format_pool.c    |    1 +
 lib/format_pool/import_export.c  |    4 +-
 lib/format_text/import_vsn1.c    |    3 +-
 lib/metadata/crypt_manip.c       |  266 ++++++++++++++++++++
 lib/metadata/lv_alloc.h          |    3 +-
 lib/metadata/lv_manip.c          |   29 ++-
 lib/metadata/merge.c             |   32 +++-
 lib/metadata/metadata-exported.h |   20 ++
 lib/metadata/metadata.c          |    2 +
 lib/metadata/segtype.h           |    6 +
 lib/misc/configure.h.in          |    6 +
 libdm/.exported_symbols          |    1 +
 libdm/libdevmapper.h             |    4 +
 libdm/libdm-deptree.c            |   31 +++-
 test/t-crypto-usage.sh           |   54 ++++
 tools/args.h                     |    5 +
 tools/commands.h                 |   30 ++-
 tools/lvchange.c                 |    7 +
 tools/lvconvert.c                |  125 ++++++++++
 tools/lvcreate.c                 |  167 +++++++++++++-
 tools/toollib.c                  |    6 +
 tools/vgchange.c                 |    7 +
 41 files changed, 2723 insertions(+), 35 deletions(-)
 create mode 100644 lib/crypt/crypt.c
 create mode 100644 lib/crypt/key_handlers.c
 create mode 100644 lib/crypt/key_luks.c
 create mode 100644 lib/crypt/lvm-crypto.h
 create mode 100644 lib/crypt/masterkey.c
 create mode 100644 lib/crypt/password.c
 create mode 100644 lib/crypt/pbkdf2.c
 create mode 100644 lib/crypt/pbkdf2.h
 create mode 100644 lib/metadata/crypt_manip.c
 create mode 100755 test/t-crypto-usage.sh


