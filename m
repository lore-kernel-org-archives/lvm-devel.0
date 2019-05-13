From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 13 May 2019 03:59:11 -0400
Subject: v2_02_185 annotated tag has been created
Message-ID: <201905130759.x4D7xBSW013939@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb59c874e027b756d67e9ab00c24336cd42ab2a1
Commit:        cb59c874e027b756d67e9ab00c24336cd42ab2a1
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2019-05-13 07:51 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2019-05-13 07:51 +0000

annotated tag: v2_02_185 has been created
	    at cb59c874e027b756d67e9ab00c24336cd42ab2a1 (tag)
       tagging 3aeff09bd7db18e4cb83c44b52eae0acac755201 (commit)
      replaces v2_02_184

Release 2.02.185

Bug fix release.

Notable changes:

Use pselect in daemons to avoid race during shutdown causing hanging process.

Automatically grow _tmeta when thin data gets too big for the metadata volume.

Grow _pmspare when extending _tmeta.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJc2SKIAAoJELkRJDHlCQOf3DYP/A0CRyrHg/VQVc1jw/X2sl2r
AjnuulJH8cNaYumZdg1wdx00gGRKG5j90/3tUBpN1u06GPrKFon1YhOhW3GkFkh3
stWrWt5z7QyP2/TymU+KJt+s87WGPjGg28vx26SYGC4F0I3lnZGNA7GAj1+hgMhU
mWPlXRexPWI9BMwDZrhPNdvgL+WVKI6RNXS7RU9SOJg1f/v8bmBRanuP1MEs2dJz
zXLlKPCtBlbntS8Xe0jh5c9IYoFi5mYA0EC+1HlvYR6x/i5WNil0K7Bd97CUgviI
VJ6/onCJiJRkLEh4UyqDLLWa2xLQGkSmBZCZ9sKLv+a+8ERWQxQn/obd0HAL35I+
dS+7hQnqm9nUBCyr8LCVVx5IFnwLPBF+NtCeCndrRSPsooCQDAVnXVFceVudg/BL
MwLDkiXO6vBIV+jK551eJUdSfpl85g9sr6oHfD9k0qte7W1gTfi4gLqxqWAB3jNl
GsqwdCDGN80pABK2hqVRLZlwrUfW9igwFHGdV/gcFLAwkX0gneWgB2M50gQX/Ben
rt0hBlJV0Lr/Vs2fmKQHgNLoouq7WZfjha9DxuKDzmKo6DTJ4aZwrK71UAla3yWl
Z9xVndUBjrV0OR83Hd6i4VyWySf+nIP4W9BTBcNgHEV9jFH4LXSRf1VL/jfue5yf
uMn9LU6a33HCReKbBPqn
=+QG1
-----END PGP SIGNATURE-----

David Teigland (1):
      devices: drop open error message

Heinz Mauelshagen (1):
      lvconvert: can't create cachepool with RAID1 metadata SubLV

Marian Csontos (4):
      post-release
      bcache: Fix memory leak
      Wiping require exclusive actvation
      pre-release

Peter Rajnoha (2):
      systemd: add missing Before=shutdown.target to LVM2 services to fix shutdown ordering
      systemd: put back DefaultDependencies=no for lvmpolld and lvmetad socket unit

Zdenek Kabelac (21):
      configure: check for pselect
      libdaemon: use pselect to avoid condition checking race
      gcc: cleanup const warning
      cache: support vgsplit
      tests: check vgsplit works with cache
      cleanup: missed string specifier
      libdaemon: ensure threads are reaped before checking shutdown
      thin: introduce estimate_thin_pool_metadata_size
      thin: resize metadata with data
      thin: fix maintenance of _pmspare
      tests: check auto-growth of thin-pool meta
      activation: synchronize before removing devices
      lv_manip: insert remove layer skips pools
      thin: select chunk size as power of 2
      lv_manip: better work with PERCENT_VG modifier
      tests: rounding for pools changed to power of 2
      tests: extend
      tests: update parm for new kernel
      monitoring: fix monitoring change for cluster
      metadata: allow reading metadata with invalid creation_time
      tests: check accepting out-of-range creation_time


