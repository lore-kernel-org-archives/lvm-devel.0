From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 21 Mar 2023 12:39:20 +0000 (GMT)
Subject: v2_03_20 annotated tag has been created
Message-ID: <20230321123920.B49153858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aba3b33d3778ad28b445130ebaa8efca4ddba844
Commit:        aba3b33d3778ad28b445130ebaa8efca4ddba844
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2023-03-21 12:37 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2023-03-21 12:37 +0000

annotated tag: v2_03_20 has been created
	    at aba3b33d3778ad28b445130ebaa8efca4ddba844 (tag)
       tagging 3e0ee8dbad69b01c63b13f41ba449cba48756968 (commit)
      replaces v2_03_19

Release 2.03.20

Bugfix release
-----BEGIN PGP SIGNATURE-----

iQJIBAABCAAyFiEE1QGkeEQK4v0TChvouREkMeUJA58FAmQZpRcUHG1jc29udG9z
QHJlZGhhdC5jb20ACgkQuREkMeUJA5++4w/+NplVlNL5sEU+AkBbKRGsN80A9fEg
0JVeB0x1G/YPzx5n922Umvu3RycoeDTAMg8/HL0ClG6NEgBO60+XRkXU38BmCEFH
bOPLJvmriJbNHYu9a3PD2lLzfwyfoG5Vh8aqoyV9pz2Y4BARVZAc0OH5AQUFbmOL
xCoGcvbYCGgGIbir7J5r6KMVxuiQfGvHPVTi89+Y7pW07fyT6jsSFGXNPsY/iQ4h
ITfYGUud+47HIt5pvm/QvQS6lX6Ck3Z5oYU8x+SkrAbwu9NRYAKlxIU70duynv4Y
SsCPhhPCjdpH+o0F0me/u9xFSG1jZ69EtEit3L0Urq+e/HB0tpY8PzWkom2VGZxI
T9LCVicKNDS5X99XQvE0iG7GPHscLrq+lbyLG1cj5+ASA5osY/lg+7ptnij5qpgG
CnEKBbDmdk8McIYxwGaGewZ3qucs25gNjSvCeoS8aZbjczoz9i4vfRcBEvH67PFI
yHrFOwk3mhC5SDizDxKt7gXCQSy/Pw/t4e/FvvjQkwG22pSk4IXiKL2FoGGGsbV6
j3lukwRY7QkUvPnNQeSjSffsm7cNo9uobrwqvWoLrQ4Z9mq2gu27tqpSLom5LeL6
wc1Hgr+FfyDirHBTd0+wI1burnL2EHHjnGuXYbgiEaU8JYUbndxlBWI7CjK8Yf1x
z526Z8jMsRTr5fg=
=P9Qa
-----END PGP SIGNATURE-----

David Seifert (2):
      makefiles: add pthread to libdevmapper pkgconfig
      configure.ac: add STATIC_LDFLAGS

David Teigland (8):
      vgimport: invalidate hints
      lvresize: fix check for mounted and renamed LV to handle spaces
      lvmlockd: clean up get_local_nodeid
      vgchange: allow changing system ID with majority of PVs
      tests: vg-raid-takeover
      vg_read: keep MISSING_PV when device with no mda reappears
      tests: update missing-pv
      tests: nomda-restoremissing

Marian Csontos (3):
      post-release
      make: generate
      pre-release

Peter Rajnoha (1):
      toollib: fix segfault if using -S|--select with log/report_command_log=1 setting

Robin H. Johnson (1):
      configure.ac: use pkg-config to detect static libs

Tony Asleson (22):
      lvmdbustest.py: Remove use of root_dir in glob
      lvmdbusd: Add lock to prevent concurrent lvm shell access
      lvmdbusd: Remove unused import
      lvmdbustest.py: Increase udev timeout
      lvmdbustest: Add more output for test_log_file_option
      lvmdbustest: Don't hard code to /tmp
      lvmdbustest: Add more info on asserts
      lvmdbustest: Test duplicate VG rename
      lvmdbusd: Move cfg.lvmdebug data init
      lvmdbusd: Add needed env. variables
      lvmdbusd: Replace assert with exception
      lvmdbusd: Handle missing key in get_key
      lvmdbustest: open log file with "a"
      lvmdbustest: Correctly set up env. for error injection
      lvmdbustest: Only inject 1 missing key error
      lvmdbustest: Shutdown cleanly with "exit"
      lvmdbusd: Add a retries during initial load
      lvmdbustest: Don't use hard coded /tmp for error inject log
      lvmdbustest: Check for needed env. variables
      lvmdbustest: Add env. variable to skip signal testing
      lvmdbustest: Add notes on error injection testing
      lvmdbustest: Correct env. logic

Vojtech Trefny (1):
      lvmdbusd: Add a new 'Shared' property to the Vg interface

Zdenek Kabelac (12):
      tests: some skips with 6.2 kernel
      tests: add fixme
      tests: remove option chunk for mdadm raid1
      tests: use aux mdadm wrapper
      tests: add missing quotes
      aux: lvmdbus checks for JSONDecodeError
      makefiles: avoid grep
      configure.ac: update dlm check
      configure.ac: fail configure for missing libraries
      configure.ac: misc
      WHATS_NEW: updates
      configure: update

