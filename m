From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Jul 2015 15:59:11 +0000 (UTC)
Subject: v2_02_124 annotated tag has been created
Message-ID: <20150703155911.08A6C60E2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c1668e2218721473193e8bef93bdf775cec0e89
Commit:        6c1668e2218721473193e8bef93bdf775cec0e89
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-07-03 15:55 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-07-03 15:55 +0000

annotated tag: v2_02_124 has been created
	    at 6c1668e2218721473193e8bef93bdf775cec0e89 (tag)
       tagging 36ce97c6250a513c73e388261ccb376cd351e11f (commit)
      replaces v2_02_123

Release 2.02.124.

This release includes experimental lvmlockd code which is still under
active development.  If you enable and use this feature, upgrading to
future releases might require manual intervention if we introduce
incompatibilities.

115 files changed, 17287 insertions(+), 553 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlWWsGcACgkQIoGRwVZ+LBdPQACeKbwBnsWs+pTIA44G+NT+SRPG
vsEAnRnqNhe6IldFJA4Q6nae3rXY6uiH
=DI93
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      locking: Add missing error handling.
      pre-release

David Teigland (2):
      Add lvmlockd
      lockd: fix stub functions for LV locking

Peter Rajnoha (8):
      config: report/time_format appeared in v2.02.123
      report: fix regression while selecting string fields using synonyms
      tests: add test for 454782f (select with synonyms for string field types)
      report: adjust shared flags based on expected type for reserved values
      cleanup: commit fe70b03 turned lv_time to STR, put it back to TIM
      report: add infrastructure to recognize fuzzy reserved names and returning dynamic reserved values
      report: call appropriate handler to evaluate fuzzy reserved names and dynamic reserved values
      report: select: add handler to recognize fuzzy time specification

Zdenek Kabelac (7):
      libdm: add helper function to print _node_name
      libdm: enhance tracing messages
      display: missed to count with 0
      thin: check for overprovisioning
      libdm: support for posting messages in suspend
      thin: move pool messaging from resume to suspend
      tests: update for new thin pool messaging


