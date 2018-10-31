From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 10:58:03 -0400
Subject: v2_03_01 annotated tag has been created
Message-ID: <201810311458.w9VEw3GF002948@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1326762567c49c7305d83ac59dff819d7de964fd
Commit:        1326762567c49c7305d83ac59dff819d7de964fd
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-10-31 14:42 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-10-31 14:42 +0000

annotated tag: v2_03_01 has been created
	    at 1326762567c49c7305d83ac59dff819d7de964fd (tag)
       tagging 913c28917e62577a2ef67152b2e5159237503dda (commit)
      replaces v2_03_00

Release 2.03.01

Important bugfix release.

This addresses an issue introduced in 2.02.178 where concurrent write at the
start of the logical volume and at end of VG metadata might result in
overwriting the LV data.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb2cIFAAoJELkRJDHlCQOfXfgQAMx+8KhR3aji3hAyzfxMqmaM
EG7VO4DgoMHkXcGoiB+jiu9fFlJ0fDSExxZmMq/aIAIsJjnOwOwYMy6dCaPNq9nf
ocMJtYK4plAs6ImizJoUgyPVlACNxgbxcm6vZIdiwmiXonfwYT26pfA5c7HZYxWt
KMbF70vA0g3H8HvS8mcWXV6xmGpmyMl+MfTiMpciSIyJqYTKxXUuEQqBhaPkzPyW
g+yWt16FyFseXj5y0poDn0oRqReMECVi9LiqgaLPvQTR9redXTzJVx88cwbFjfkI
ATKtRMscAzolHieV7loNZTRrmGAcca1FQOMfj+aDHEpwpk/sqU2E9LRBTCZ2TelQ
PS6q0oi1qBaz9+9xdgs9xrFH4t/Q0/TR2O2f/TEnJ/Ar+DNMwId7di+hrOWUERSo
LH+qSfUa3XSYswYJFfwMEq4z9ZcMhaG9NSbNgSM9mI06XO2Y1GVnuM2dNe88keCQ
au2gOJb79duS0QuaEY4PBrqxDyWTtB0H74UvpGRafSf0d9WRQm4HrfxDtK79+Aww
85ogfaWmAShv7W64rFkF/deXqkWDLu1QG1WSfGok7ClWcJXTA29bEQWjY5YAv/AL
UEh116b+hfBJfGXGKczYWCaEP4MhDPPahZ2iaArZ5vIqHdG0DvHteDRphQZYpnKZ
Z89xzH6R2YYSzYpW9hbn
=wPqe
-----END PGP SIGNATURE-----

David Teigland (3):
      fix: cov: missed return value test
      tests: add new test for lvm on md devices
      metadata: prevent writing beyond metadata area

Heinz Mauelshagen (2):
      raid: fix left behind SubLVs
      Revert "raid: fix left behind SubLVs"

Marian Csontos (7):
      post-release
      build: Use PYTHON env. variable when provided
      config: Fix version for VDO
      build: make genrate config file
      spec: lvmdbusd requires python3 setuptools
      build: Fix CLDFLAGS default
      pre-release

Zdenek Kabelac (36):
      cov: missed return value test
      cov: warn about failing sigaction
      cov: drop check for pointer
      cov: dmeventd plugin fix memleak
      cov: fix memleak on bcache io error path
      cov: fix leaking openned file descriptors
      cov: index off by one
      cov: dm stats missed terminating null
      cov: fix missing null allocation check
      cov: add at least ASSERT
      cov: dmstats check for failing malloc
      cov: add check for positive value
      cov: fix typo
      cov: fix failing filter initialization
      cov: fix error path
      cov: dm node message fix missing initilization
      cov: ensure vars are set
      cov: check dev_close_immediate
      cov: check dm_strncpy result
      cov: check closedir result
      cov: log failing unlink
      cov: make sure label scans valid lvinfo
      cov: add missing error path check for label_scan_open
      cov: ignore error of vsnprintf
      cov: pvscan ensure sigle_devs list is always initialized
      cov: drop uneeded header files
      cov: avoid selfrecursive inclusion of  toolcontext.h
      revert "cov: dm stats missed terminating null"
      cov: shutdown warning
      tests: fix tested targeted
      tests: timing without /usr/bin/time
      tests: properly enforce v1
      tests: fix conf generation with older shells
      tests: add raid target presence check
      tests: better support for /var/run
      tests: missed char in list


