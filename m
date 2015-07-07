From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Jul 2015 13:00:23 +0000 (UTC)
Subject: v2_02_125 annotated tag has been created
Message-ID: <20150707130023.A8823610C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b397fb6e272f632d553971463f4a136964604cd
Commit:        7b397fb6e272f632d553971463f4a136964604cd
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-07-07 12:56 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-07-07 12:56 +0000

annotated tag: v2_02_125 has been created
	    at 7b397fb6e272f632d553971463f4a136964604cd (tag)
       tagging 3472910177c96780628c7d54dfb6b4aab735353c (commit)
      replaces v2_02_124

Release 2.02.125.

82 files changed, 1095 insertions(+), 614 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlWbzIQACgkQIoGRwVZ+LBeVCQCePpJjvDWXV2L+HtdeA4AzmDmN
7DEAnA3woE7XcoVEBmKtAT29VYxBHILG
=kZ0K
-----END PGP SIGNATURE-----

Alasdair G Kergon (6):
      post-release
      macros: Wrap PRI with FMT.
      include: Standardise around new tool.h.
      configure: Separate sanlock and dlm lock config.
      WHATS_NEW: Update. Fix renamed config setting vsn.
      pre-release

David Teigland (6):
      configure: enable building lvmlockd without sanlock or dlm
      config: rename lock_retries lvmlockd_lock_retries
      lockd: remove unused code for overriding lock modes
      config: remove read_only_lock_modes
      man lvmlockd: minor updates
      lvmetactl: program to interact with lvmetad

Jonathan Brassow (1):
      clean-up: typos s/bellow/below/

Marian Csontos (2):
      Build lockd only for Fedora >= 22 and RHEL >= 7
      lockd: Clean up spec

Ondrej Kozina (1):
      lvmpolld: fix possible memory corruption with mem debug

Peter Rajnoha (2):
      conf: regenerate
      conf: regenerate

Zdenek Kabelac (2):
      cache: support clear-needs-check
      tests: use old snapshot for huge volumes


