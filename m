From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Apr 2016 00:15:22 +0000 (UTC)
Subject: v2_02_152 annotated tag has been created
Message-ID: <20160430001522.04B2760DEC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2492903a600973fe9110285804b1c02b71d284c
Commit:        b2492903a600973fe9110285804b1c02b71d284c
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-04-30 00:09 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-04-30 00:09 +0000

annotated tag: v2_02_152 has been created
	    at b2492903a600973fe9110285804b1c02b71d284c (tag)
       tagging e53ecf91f7550b77d8b85545e49c5805332ddd8d (commit)
      replaces v2_02_151

Release 2.02.152.

More bug fixes.

23 files changed, 321 insertions(+), 116 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlcj9+QACgkQIoGRwVZ+LBe4iwCgiXA8V0KTpjBFmt7zjZxN7Nm/
ogwAoLNwaDOf6yBE1nG0KNmrSnfGCqIi
=Yxmh
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      libdm: Add dm_udev_wait_immediate.
      datastruct: Add str_list_wipe.
      raid: Use inherited tags when wiping rmeta.
      pre-release

David Teigland (3):
      metadata: fix segfault when filters reject devices
      lvmetad: improve warning after lvmetad message fails
      pvscan: autoactivation should ignore some VGs

Peter Rajnoha (4):
      metadata: log warning instead of error if device not found while checking used and assumed devs
      cleanup: do not mention segment in warning message if device not found for a PV when checking used/assumed devs for an LV
      udev: rules: remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0)
      udev: rules: add comments explaining subsystem-specific rules

Zdenek Kabelac (12):
      modprobe: check /sys/module entry first
      cache: with cache target 1.9 mq is alias to smq
      cache: check for clean cache as separete function
      thin: zero and transaction_id also with thin volumes
      lvchange: fix return code
      lvchange: always check for sigint
      lvchange: use better arg functions
      man: lvchange updates
      man: lvcreate doc passthrough
      cleanup: smaller timeout
      cleanup: use log_debug_activation
      cache: better support for alias check


