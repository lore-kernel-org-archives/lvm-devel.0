From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 1 Aug 2018 10:59:19 -0400
Subject: v2_02_181 annotated tag has been created
Message-ID: <201808011459.w71ExJZK006733@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=560872f013c65f8c1ff463be59fde9382a1b0185
Commit:        560872f013c65f8c1ff463be59fde9382a1b0185
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-08-01 14:57 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-08-01 14:57 +0000

annotated tag: v2_02_181 has been created
	    at 560872f013c65f8c1ff463be59fde9382a1b0185 (tag)
       tagging a3353e766e6989147afb44b94767b54bc7827967 (commit)
      replaces v2_02_180

iRelease 2.02.181

Bugfix release fixing mostly lvconvert command.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJbYcp8AAoJELkRJDHlCQOfp/0P/1CvDalDgTkmZlVIElU5lSq8
PVhfc6JK+yHjFz7b8uQ42Q+YGXLov5DFf7bwagsAeWOguGsRbO9hDleJwZ1iJFv1
GBezEl73W49ug0ODnCus3nYFkTiuDk6v5LrnBPeNfjDi7c2lB76Ekzdl1rle7lCc
szUk3T33AXqh6UdTiuhi94FrZEB9Oo5FWaFIapEXr0ce8GX8+DVJN6ubN92hIWxT
zu5IM25w+rc57lSeLvVb372ZOkJ7Z8TJ7VcF+FUAiXsFTTmDgP+euqjdP8i7NFD7
2p6EbJrp04ncK7k7DUPwMPkNQ78o3n/vdYjuxLGlWM28+c3SucfSboYUgI2ZUpCb
IO9Y2p5UBy8gbG35rAr3bM4NNL5+8ecmrxpab/kLh0/q8LYSd5gu9bDfBXrwPYR0
It59T4DPlP4kcwTddi1IKrerdpH7KFNLepNHKo5vp0/8uFcvtEo5wCEoHEKNFETn
wtVzx3ySZlsZz31LP0S5/aaWTmul00rG/1uE24ZOmdCTEWiza84ZwWMydiV4r/gb
WxFioJ4b/AHidDy/48Kv8rgYFnf0vPB2Qc/FQigLAY6lSjmw3Vd6g/EFvNSnEANU
jVaOp0nCOD4GpxgU0W/WUiSsDKAflg4vWdgrYAXxhyOc2BiScqpTkmkOrSvc2F9k
k1f+hAx0EL4J0fFdxecy
=Un40
-----END PGP SIGNATURE-----

Bryn M. Reeves (1):
      dmsetup: fix error propagation in _display_info_cols()

David Teigland (2):
      lvconvert: restrict command matching for no option variant
      lvconvert: improve text about splitmirrors

Heinz Mauelshagen (3):
      lvconvert: reject conversions of LVs under snapshot
      lvconvert: reject conversions on raid1 split trackchanges SubLVs
      lvconvert: reject conversions on raid1 split trackchanges LVs

Marian Csontos (6):
      post-release
      test: Check flavour is used and exists
      Add BSD 2-Clause License
      WHATS_NEW
      build: make generate
      pre-release

Zdenek Kabelac (2):
      dmeventd: base vdo plugin
      dmeventd: rebase to stable branch


