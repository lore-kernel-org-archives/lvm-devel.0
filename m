From: Marian Csontos <mcsontos@sourceware.org>
Date: Sun,  9 Aug 2020 15:01:42 +0000 (GMT)
Subject: v2_03_10 annotated tag has been created
Message-ID: <20200809150142.29E3F3857C4A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b70d52b67f2577ff5563dfb2076385d7959a6dc
Commit:        1b70d52b67f2577ff5563dfb2076385d7959a6dc
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2020-08-09 14:57 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2020-08-09 14:57 +0000

annotated tag: v2_03_10 has been created
	    at 1b70d52b67f2577ff5563dfb2076385d7959a6dc (tag)
       tagging f540a18fd7f5f65599a6c85c0bd3ba84e54f1cc8 (commit)
      replaces v2_03_09

Release 2.03.10

- Add integrity with raid capability.
- Add writecache and integrity support to lvmdbusd.
- Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
- Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
- Bug fixes.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJfMA7qAAoJELkRJDHlCQOf9oMQAMbyK53xgJ6iz65LwiZgdeS7
4G5Z7ITBs7A1xBZLGNtzkAavaRTi/dyH8Ib2HdW4wh86b7C0Lvn0lhuaWgl4DbzU
qi0Rf+G280i0G2yDjmuhlVjLZDlpDAclJXdlHZD5Wrblqn2Ovqwwe3ZcY+iUuvwo
0N5UE0JpOiC74eLstn3vf/HqJSTbP79ezG8HPUba1sQQJBC+XQdsc1I1FENLOxIx
/RORvDzrswNfbYBalgCye5DxZLxRPdh9H5Y3LsKTDpdA6WIRpcwCWRLibgp+l7FL
1oO6qQkUhcM0P4TabvN9Ev7Kx+WihFwlGkeOl5PXQgak+AvjhejToCyDB8SB32Df
zm4Fr96tdmRnsmQ1EEcayP7jnzCPJuzW6kpR3CI8hW2QJcRI73UIzBURLpGHpu89
SgT1b4H765MQIeEH108PbqRJe9u22BgSzQZJ4XBH0Jk3ImePpI6MKWjYNXNnz+F3
Od9Yfn+GffcmgECxXrOJE5NHxsTRD3UVoSH2PWNSaUf0xb6bNh1ESKU5k0yf/y9K
xanU0VzBNHeQdEhtp2M2skoyywJP24NRQvMwNzzxhJUZ9g18oV76zySVJmsAPksi
v4IVFmJzTvXRv25IDF3rf3XNxXw6s+qQGTELfC48jHCiEVZrZqOZBtWBFRmEPDxA
U2SlwUXoXpzPt+992FI+
=DUfj
-----END PGP SIGNATURE-----

David Teigland (3):
      move pv_list code into lib
      Allow dm-integrity to be used for raid images
      WHATS_NEW: integrity with raid

Marian Csontos (7):
      lvm2-rhel8
      lvm2: set default preferred_names
      lvm2: test: skip-problematic-tests
      test: warn only on unexpected pass of a known bug
      build: make generate
      Merge master up to commit 53803821de16
      Merge master up to commit be61bd6ff5c6

Maxim Plotnikov (1):
      Fix scripts/lvmlocks.service.in using nonexistent --lock-opt autowait

Peter Rajnoha (1):
      blkdeactivate: add support for VDO in blkdeactivate script

Zdenek Kabelac (3):
      lvconvert: no validation for thin-pools not used by lvm2
      test: repair of thin-pool used by foreign apps
      WHATS_NEWS: update


