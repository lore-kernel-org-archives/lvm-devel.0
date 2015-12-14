From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 14 Dec 2015 12:31:40 +0000 (UTC)
Subject: v2_02_138 annotated tag has been created
Message-ID: <20151214123140.429286105B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5be7677e50b7bb82d788e7bdc53d17785108bc4
Commit:        a5be7677e50b7bb82d788e7bdc53d17785108bc4
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-12-14 12:25 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-12-14 12:25 +0000

annotated tag: v2_02_138 has been created
	    at a5be7677e50b7bb82d788e7bdc53d17785108bc4 (tag)
       tagging 3e8126a66acb57c9cad75948eed4d8e2f0c347aa (commit)
      replaces v2_02_137

Release 2.02.138.

14 files changed, 200 insertions(+), 67 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlZutSsACgkQIoGRwVZ+LBdlQgCdEXHzH71L10/u97ua4QuAa8qE
F+sAninMOqDHyXZOu56aiubzxVTRlHXn
=Grrj
-----END PGP SIGNATURE-----

Alasdair G Kergon (4):
      post-release
      dmeventd: Extend checks on client socket.
      dmeventd: Don't trust fifo with wrong attrs.
      pre-release

David Teigland (3):
      lvrename: move the lvmlockd LV lock
      lvmlockd: reconnect to lvmetad if it's restarted
      Change messages from verbose to debug

Riku Voipio (1):
      fix static linking

Zdenek Kabelac (5):
      cache: support stacked rename
      lvrename: always allow to rename pools
      tests: fix logging
      tests: check lvrename of stacked cache pool
      cleanup: add missing WHATS_NEW


