From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Mar 2020 12:46:56 +0000 (GMT)
Subject: v2_03_09 annotated tag has been created
Message-ID: <20200326124656.4E048385E00B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21d1cf58071b07c598f57de4f1adaf049a8e528b
Commit:        21d1cf58071b07c598f57de4f1adaf049a8e528b
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2020-03-26 11:22 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2020-03-26 11:22 +0000

annotated tag: v2_03_09 has been created
	    at 21d1cf58071b07c598f57de4f1adaf049a8e528b (tag)
       tagging e1c2b4126520f05a5d2d515121e89263ec45a2bf (commit)
      replaces v2_03_08

Release 2.03.09

- Fixed compilation errors with GCC 10.
- Fixed few writecache and pvck releated bugs.
- Fixed busy loop in dmeventd.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJefJFYAAoJELkRJDHlCQOfByAQAPm6Zhaaww/yoLXQDrP0F/jg
MWLHsKLa8QHiwCMDK56z1mXSFHVKJYW3XVEKn0CiyU6VNOwUNrQJesGlkq8ZdWjv
yfpSldDNUp8co9dL9uJYCcliWVh9yL0dhj358Phzb6Su4J6fRw6udyI8KSkbTD2F
Rlms4j3caIn7YR81OHu6aaKQzKDvohzI8uuydcjn+BRjgn8OOema6aWFFgt5dGPy
HZyexIcQZRROCmDDq4qQk1PJOF3iaLNpfUxA9moTzfV8q8CuqvCTjr83GRlkW+iD
ePIqfrkYTMlfYZpWgMhQg+QqAKAQubMggrP0cnuEA6ZA3gm6RplIz5yGtbu0EvK2
QWSzs/7w8iQKLbW14XrmIy+DHgF3zrkWl9398AHBHfdmuUQ5DD+7IMFa35Ok9ZX6
HMvQ7X2FuFNxHhj5EzTJpFnpbEzI2J80I17Xm97DuM/XsWoWJGltBvzNH2xJ9mM2
0qEuOcWCIZ0NAKhZOAGdyPmAX+2h7WqnhM8v1/EcHEdEOppFx3I1zo4zsmpgYK5J
IJiTqQco8sTIFA2kPBg0Jh4BIlkX7QmWR5yqPdkDAtoy6ZpXNeMx8mtM8WCsyF8r
r5pEEcCEbrTks63VqiydfhCnDoa6Lp71gewvcrkjdno64G83d5hbKVQsysgvWAfb
27+l0LxzBcmBKIEaC5e0
=1eeh
-----END PGP SIGNATURE-----

David Teigland (20):
      writecache: check if cachevol is writable
      thin: don't use writecache for poolmetadata
      writecache: drop real dm suffix
      writecache: working real dm uuid suffix for wcorig lv
      writecache: fix watermark error message
      writecache: allow removing wcorig lv
      writecache: check watermark value
      hints: free hint list in error exit path
      pvck: ensure text lines are terminated
      pvck: print longer command description
      pvck: improve mda_offset mda_size choices
      pvck: fix reading large mda1
      pvck: allow dump from file
      tests: pvck dump from larger metadata areas
      tests: reduce sizes in pvck-dump and improve checks
      pvck: use dm_config_parse_without_dup_node_check
      writecache: require inactive LV to attach
      lvmlockd: use transient LV lock when creating snapshot
      man: lvm2-activation-generator fix vgchange comment
      reduce device path error messsages

Jonathan Brassow (1):
      man: lvmcache raid1 references

Marian Csontos (4):
      post-release
      test: Can not attach writecache to active volume
      test: Fix previous commit
      pre-release

Zdenek Kabelac (8):
      cachevol: stop dm errors with uncaching cache with cachevol
      vdo: fix slab size bits calculation
      tests: validate vdo slab_size
      dmeventd: enhance time waiting loop
      libdm: fix dm_list pointer arithmentic for new gcc 10 optimization
      container_of:  use offsetof from stddef
      WHATS_NEW_DM: update
      vdo: make vdopool wrapping device is read-only



