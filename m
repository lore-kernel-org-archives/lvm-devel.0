From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 21 Apr 2023 08:43:33 +0000 (GMT)
Subject: v2_03_21 annotated tag has been created
Message-ID: <20230421084333.CB3403858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6c8d2429ce4d4a13750f271987702d3e2648904
Commit:        a6c8d2429ce4d4a13750f271987702d3e2648904
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2023-04-21 08:40 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2023-04-21 08:40 +0000

annotated tag: v2_03_21 has been created
	    at a6c8d2429ce4d4a13750f271987702d3e2648904 (tag)
       tagging 54efdab230ec4f6d10ffdb9170b07c0664c157ea (commit)
      replaces v2_03_20

Release 2.03.21

Mostly bugfix release.

Allow (write)cache over raid+integrity LVs.
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmRCTFgUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA5+9DhAAg2MEQKqTajeii61DteENXdmR2hUi
PiMDZF3WjwORxxrjut+c5B/Lvj3gDPnkxPjHJ7SXEQzrBly6Wec5r+i9iRgSdQkj
5XnGMdkm3qz9KeQgFz6U5/tWBT8EV3ux7ZZEIITKIZyyWQeVUIlLlrkJHoECqlDe
b3yM3EY/0K8cs2KVEbvXnKDlSZPn6Q980tE60Tt0MUbLOfxiJNdopNzT4RcHaJW9
A0PTmhHVzJjTla00Y3mRBPy16mQrztkeaC/WDxHx6XhCspd0I251rrrthLH+6szA
nS/ISXwdWCOlZDx4WjpZY35EPcfaAGk2ADrVLuB3Tk073nYSTFpBO596VvYvEkwl
TMBb4xqR81jMbOnUSRgGdAoGFOKwcQ0q5HXaVaq4UZZy50Ot36fPCpLDrrxT+2LI
xVrzgayTdEIgJqFetsGuT2+zqhdIH7iV76Jy/vpFf6Yvq9+4YIdlgxkhPU2RKWR9
rQiocPBkMta83meD9pklyJMlGp27ECSrwQpEaQLbQrlHp+b2vE1T+3OXbpeD4ns/
ytk5IIorKMFv4k8LdkSbfttObcSks1znMrLJj9HnObKmuTcpLPpNwAjNzSYswD4h
Hw3RPA8+OWoa0hgA0hRH8U57rU0EQEyJjQMQZJjKfu52YXVZTjiszvWtaPbwTqn1
upppjSiwzZxjAMU=
=uCmk
-----END PGP SIGNATURE-----

Adam Williamson (1):
      Fix import of utils from lvmdbusd.cfg

David Teigland (5):
      tests: integrity fixes
      raidintegrity: allow writecache and cache
      support 16KB page size
      remove extra change from support 16KB page size
      cache: fix snapshot of cache with cachevol

Marian Csontos (2):
      post-release
      pre-release

Tony Asleson (2):
      lvmdbusd: Correct locking for _common_log
      lvmdbusd: Correct seg. fault on s390x ELN

Vojtech Trefny (1):
      lvmdbusd: Add a flag to activate LVs in shared mode to Lv.Activate

Zdenek Kabelac (9):
      integrity: hide creation of internal LVs
      configure.ac: print locking dir
      configure: update
      cleanup: simplify
      cleanup: rename function
      vdo: use fixed size vdopool wrapper
      tests: lower demand for disk resources
      tests: use less demanding ext4
      WHATS_NEW: update

