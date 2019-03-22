From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Mar 2019 06:17:50 -0400
Subject: v2_02_184 annotated tag has been created
Message-ID: <201903221017.x2MAHonX011753@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44fed6a37b24bb278914e59909cb406b78217bb9
Commit:        44fed6a37b24bb278914e59909cb406b78217bb9
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-03-22 10:04 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-03-22 10:04 +0000

annotated tag: v2_02_184 has been created
	    at 44fed6a37b24bb278914e59909cb406b78217bb9 (tag)
       tagging 7cbee7e9cf5445ee5c50898e20536734cbb0f4a6 (commit)
      replaces v2_02_183

Release 2.02.184

Bug fix release.

Notable changes:

New scan_lvs option with default setting 0, which filters out logical volumes
from scanning for PV headers.

Fix issue with cleaner policy not working with large cache volumes where
migration threshold was smaller than chunk size.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJclLTzAAoJELkRJDHlCQOf3cYQAJ0c4pnE0WZuXzPv2AGbgPBi
qlEXe7IWA6BcffGb31IvyDTQZhheKhsf4B3ogYatg8naCFZw6grBZZaO8A2XWq9U
rd8TDomna2HBCeFrrYQNLnQTajlOVFrvQXYoQbpk4OkF9qRPVEzWH4LSbG3Qicrt
6mRQt8FiTnjBixw/fynarkDMWy+TDBtucBgTc6L62kuqCqbZMaeooaBBCRpKublZ
RM22U087Ll1ZMPuunj1AYWiQp+qEiHbSPzuaRjhTacWm3ObchrKgPy3rlGqbULte
14UYRorjsjGUJ0uQKCOq46iDtZkQzbBHYacfxdiiO25V8SmV/egJLjtj9Wv+oHz1
e8UPwr1xXmhoxrAeLdsQQlFwyOaxXNlD8fgWIe8/z+ReWRs204i4liMdqnrDa/8M
FhiaExWgD+e+guEefCHrD0DXYuNf6rn9UIdZxyeNvppYM7JxpKtnBr2HeDElR/4R
SvJaTj9/X8ObKhbLpRCNpikPgYvdhDVgPuDV2JE/1fTnoRr0LKtPg+pT3FITRSw0
lqkkXYnwl5te4m9WYLuDtnGTzgslrrl59dH9D39WQG0uayPgmoRHyn2PwEtD4E/v
X9YZplS6LB0VwLDjUftRHkcs+7Dn+/4Xw9eU7zCSCPFWu8Nv6iYfe3nt9BIb8TCA
IbACPxvMAMLov01Um4co
=VcrO
-----END PGP SIGNATURE-----

Alasdair G Kergon (1):
      dmsetup: Fix multi-line concise table parsing

David Teigland (13):
      lvmlockd: make lockstart wait for existing start
      lvmlockd: fix make lockstart wait
      apply obtain_device_list_from_udev to all libudev usage
      filter: add config setting to skip scanning LVs
      config: change scan_lvs default to 0
      tests: set scan_lvs=1 in tests that stack PVs on LVs
      WHATS_NEW: scan_lvs
      tests: add scan_lvs.sh
      config: add new setting io_memory_size
      io: warn when metadata size approaches io memory size
      io: increase the default io memory from 4 to 8 MiB
      config: improve scan_lvs description
      pvscan: lvmetad init should set updating before scanning

Heinz Mauelshagen (1):
      raid: fix (de)activation of RaidLVs with visible SubLVs

Marcos Paulo de Souza (1):
      pvscan.service.in: Move StartLimitInterval to Service section

Marian Csontos (5):
      post-release
      spec: Use python3 setuptools with python3
      cov: dmstats check for failing malloc
      build: make generate
      pre_release

Ming-Hung Tsai (1):
      lvmanip:  uninitialized members in struct pv_list (#10)

Zdenek Kabelac (15):
      cov: dm stats missed terminating null
      cov: ensure vars are set
      revert "cov: dm stats missed terminating null"
      cov: shutdown warning
      cov: split check for type assignment
      cov: mark warning as expected one
      cov: hide intentionaly ptr arithmetic report
      cov: remove unused assigns
      cleanup: move cast to det_t into MKDEV macro
      libdm: add DM_DEVICE_ARM_POLL
      libdm: print params only for ioctls using them
      libdm: add memory barrier
      stats: fix error path when region is NULL
      stats: initilize regions to NULL
      dm: migration_threshold for old linked tools


