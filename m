From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Dec 2018 09:17:06 -0500
Subject: v2_02_183 annotated tag has been created
Message-ID: <201812071417.wB7EH65D013035@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f21d9eb8527258479805f5a8132dd9e6e3e572d8
Commit:        f21d9eb8527258479805f5a8132dd9e6e3e572d8
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-12-07 14:13 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-12-07 14:13 +0000

annotated tag: v2_02_183 has been created
	    at f21d9eb8527258479805f5a8132dd9e6e3e572d8 (tag)
       tagging f5ea02ffee3269a77e295d2b186ca81481f592d7 (commit)
      replaces v2_02_182

Release 2.02.183

Bug fix release.

Use sync IO when AIO fails due to system reaching the aio request limit. Add
global/use_aio configuration option to disable aio.

MD RAID verion 0.90 devices are filtered out preventing them to be seen as
duplicate PVs.

Fix regression in dmstats resulting in no output.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJcCoAQAAoJELkRJDHlCQOf6FUP+gNHcULrPp8Tv47Hk6LOOY6x
G6YEkwEmks070B3FPPLGJ49YuGbuiiGhbBdBKajaOiubTStuEc2cFO597kCV8SlX
TwNF9NEGCUy3XyhqAXStZb3nOEZo0pO7ZZsnwlkfEOWb/R+2fcGA+c6SwLUoOwbx
NZYBRCCdaTcVdJhD0qNjz1SrZ5GREQjXDwfSN+uqAw+QwWWWsqZd+hrlM86mEIer
cls2EfhNkEV7UBqi6CS7d9uzQNpLuul//jOmggH1q39rVw7ZxCLv6wPQOVR9Z+xm
T7Do3w2kmy0wsmcdxRcOJ8POeh7nSJApU3owa2BjBEetRwyxfDhdNcsjG52XHCIx
l9PyG6VNvg92FeDVkkOxGLQP9bd76+u4JiRzyzMjYczuCEbbV4Yhwud3MoHA1/fU
E0kD7FWImPIRudS5GR0XRTfZB/hT4LaL0k2RDtMYr2IIfEsixgWEPwMD0P9RrYnS
vTKnAm62oO2TLvkIFq+D5vguEjg9JLz5xV3NV3yZGCe6YiShaz0C0LScmAOCIpq7
YQ2xPBGBKKuYDsA1TEgUXzaPX6qtZQhQ2CC25OR4PL/z2d7eotVlcjNSChZgKOLt
g8j7CKKqgp8R5F5SKPHbGHVtNqkWUYmUQbRSgtFwl0wCTIoFILt0NnbDO9XEVjD3
f7uAulpVklECGeS76zKr
=4F0E
-----END PGP SIGNATURE-----

Bryn M. Reeves (2):
      libdm-stats: move no regions warning after dm_stats_list()
      dmsetup: fix stats report command output

David Teigland (9):
      devices: reuse bcache fd when getting block size
      update WHATS_NEW
      io: use sync io if aio fails
      bcache: sync io fixes
      WHATS_NEW: sync io
      pvscan lvmetad: use full md filter when md 1.0 devices are present
      lvmetad: only disable if repair will do something
      lvmetad: fix disabling in previous commit
      pvscan lvmetad: use udev info to improve md component detection

Marian Csontos (3):
      post-release
      build: make generate
      pre-release

Peter Rajnoha (1):
      scan: md metadata version 0.90 is at the end of disk

Zdenek Kabelac (1):
      libdm: do not add params for resume and remove


