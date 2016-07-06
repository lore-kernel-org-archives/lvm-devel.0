From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  6 Jul 2016 16:04:35 +0000 (UTC)
Subject: v2_02_160 annotated tag has been created
Message-ID: <20160706160435.4F8BF6147C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bd5bad869cebc622a73087ebb665f4b5ee66a43
Commit:        3bd5bad869cebc622a73087ebb665f4b5ee66a43
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-07-06 15:56 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-07-06 15:56 +0000

annotated tag: v2_02_160 has been created
	    at 3bd5bad869cebc622a73087ebb665f4b5ee66a43 (tag)
       tagging 8ca874bc1f958cc2138bf13cbed492de5daff0c3 (commit)
      replaces v2_02_159

Release 2.02.160.

Minor fixes from coverity.

9 files changed, 66 insertions(+), 20 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAld9Ki4ACgkQIoGRwVZ+LBd00wCg8A73SQ/fyjwvyueby0gx+COk
x40An1WpY9HmMbK6fc2u8aeOFv9+4Ucr
=yurb
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      coverity: Fixes for recent changes.
      pre-release

Bryn M. Reeves (9):
      libdm: fix mask leak in dm_bitset_parse_list
      libdm: restore missing braces in _stats_walk_end_areas
      libdm: test for zero interval_ns in _utilization() (Coverity)
      libdm: check non-zero io count in _average_{rd,wr}_wait_time (Coverity)
      dmstats: fix 'obj_type' field width
      dmstats: simplify nr_areas calculation (CWE-561)
      libdm: do not permit grouping regions with histograms
      libdm: use log_err_once() for group histogram message
      libdm: check for empty aux_data in _parse_aux_data_group()


