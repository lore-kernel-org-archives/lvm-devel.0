From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 15 Aug 2016 12:25:39 +0000 (UTC)
Subject: v2_02_164 annotated tag has been created
Message-ID: <20160815122539.32BBC607C6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=97bb0c29b9bfae6a2077d62cfca40a75da5e679f
Commit:        97bb0c29b9bfae6a2077d62cfca40a75da5e679f
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-08-15 12:18 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-08-15 12:18 +0000

annotated tag: v2_02_164 has been created
	    at 97bb0c29b9bfae6a2077d62cfca40a75da5e679f (tag)
       tagging 829727696700ac509e8e89f669245947e830c8f6 (commit)
      replaces v2_02_163

Release 2.02.164.

Bug fixes for the new lvconvert and lvmdbusd functionality.

14 files changed, 133 insertions(+), 27 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlexsz0ACgkQIoGRwVZ+LBcc7QCfVr3/o5spHBLpl4kX1NEhijVy
fX8AoOfwhCB1oCSusnd2ryVTRfkaC1at
=Zz7B
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      raid: Avoid double suffix on rmeta LV name paired with rimage LV.
      pre-release

Heinz Mauelshagen (3):
      lvcreate/lvconvert: fix validation of maximum mirrors/stripes
      raid_manip: add missing code avoiding MetaLV collocation on the same PV
      raid_manip: pay attention to PVs listed on command line when allocating MetaLVs

Marian Csontos (1):
      spec: Add new files

Peter Rajnoha (2):
      lvmcmdline: use long int for number returned by strtol
      conf: add comment about cfg_runtime

Tony Asleson (1):
      notify: Fix hang with lvm shell & --enable-notify-dbus


