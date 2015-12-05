From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Dec 2015 15:57:24 +0000 (UTC)
Subject: v2_02_137 annotated tag has been created
Message-ID: <20151205155724.700E3602B8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d1f7849b5a902c7809b7ffcc1e16ef1e0138e08
Commit:        2d1f7849b5a902c7809b7ffcc1e16ef1e0138e08
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2015-12-05 15:33 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2015-12-05 15:33 +0000

annotated tag: v2_02_137 has been created
	    at 2d1f7849b5a902c7809b7ffcc1e16ef1e0138e08 (tag)
       tagging 063b353b286652d5ccc692cf636824b9b3270fe9 (commit)
      replaces v2_02_136

Release 2.02.137.

Another development release.

49 files changed, 1263 insertions(+), 637 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlZjA/oACgkQIoGRwVZ+LBdEcwCfaNhyqTQ7t6dFc31yoGhJ+z1F
vZ0AoLwTPSJE49GhLhIUQPGTAI6f04/x
=kXAy
-----END PGP SIGNATURE-----

Alasdair G Kergon (5):
      post-release
      lvconvert: Improve message for raid without -m.
      lvconvert: Reinstate mirror to raid conversions.
      lvconvert: Reinstate raid merge after splitmirror.
      pre-release

David Teigland (16):
      lvmetad: include both vgid and vgname in lookup request
      lvmcache: include system_id in vginfo cache
      system_id: refactor check for allowed system_id
      lvmcache: new function to check if VG is foreign
      process_each: always use list of vgnames on system
      process_each: resolve duplicate VG names
      toollib: remove unused function
      vg_read: look up vgid from name
      lvmcache: change duplicate VG name warnings to verbose
      vgextend: pass single vgname as process_each_vg arg
      lvcreate: use process_each_vg
      lvrename: use process_each_vg
      lvresize: use process_each_vg
      toollib: allow VG UUID to be used in place of VG name
      toollib: only interpret vgname arg as uuid for vgrename
      man lvm: add section about unique VG names

Zdenek Kabelac (16):
      libdm: introduce  dm_get_status_mirror
      tests: unit test for mirror status
      lib: pass mem pool to check_transient_status
      cleanup: use dm_get_status_mirror
      mirror: fix condition
      uuid: add id_read_format_try
      cleanup: use try_id_read_format
      log: use full buffer size for printf
      archiver: inital change toward proper logging
      cleanup: drop log_suppress(2) usage
      vgextend: reinstantiate archiving
      tests: check read-only backup archive
      libdm: add some doc for mirror status
      debug: correct stack tracing
      archiver: fix reporting for check_current_backup
      tests: extend test


