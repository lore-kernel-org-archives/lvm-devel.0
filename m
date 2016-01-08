From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jan 2016 18:59:59 +0000 (UTC)
Subject: v2_02_139 annotated tag has been created
Message-ID: <20160108185959.94B4760068@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a52e23085dd84bb3b62d44cd28b421004c7a19c5
Commit:        a52e23085dd84bb3b62d44cd28b421004c7a19c5
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-01-08 18:47 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-01-08 18:47 +0000

annotated tag: v2_02_139 has been created
	    at a52e23085dd84bb3b62d44cd28b421004c7a19c5 (tag)
       tagging 04b82a81262c2da3b7254c884e6df46d59c69c4a (commit)
      replaces v2_02_138

Release 2.02.139.

21 files changed, 330 insertions(+), 193 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlaQBGgACgkQIoGRwVZ+LBeXRACg0L0Xsfn9Be8RSX+t+zcAKqxT
VuYAn3xQ2DZSLSRJ1bjOZQ+23A3heErl
=5QIx
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      pvscan: Remove duplicate filter wipe.
      pre-release

David Teigland (4):
      process_each_pv: do full scan earlier to find new devices
      vgrename: use process_each_vg
      lvmlockd: update VG lock version earlier
      document commits since last release

Peter Rajnoha (2):
      lvmdump: also add lvm2-activation{-early,-net}.service systemd status for lvmdump -s
      man: lvs: document F,D and M thin pool health status chars for lv_attr in lvs man page


