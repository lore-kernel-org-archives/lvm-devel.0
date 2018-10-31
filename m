From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 03:51:47 -0400
Subject: v2_02_182 annotated tag has been created
Message-ID: <201810310751.w9V7plmD004025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d64377b5bbd2d170f1d6365157e2245d90a63c1a
Commit:        d64377b5bbd2d170f1d6365157e2245d90a63c1a
Parent:        0000000000000000000000000000000000000000
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    2018-10-30 09:10 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: 2018-10-30 09:10 +0000

annotated tag: v2_02_182 has been created
	    at d64377b5bbd2d170f1d6365157e2245d90a63c1a (tag)
       tagging b93aded0212a903f8a1e9e897dada1f34aa3de43 (commit)
      replaces v2_02_180

Release 2.02.182

Important bugfix release.

This addresses an issue introduced in 2.02.178 where concurrent write at the
start of the logical volume and at end of VG metadata might result in
overwriting the LV data.

Also MD RAID version 1.0 devices are correctly filtered out preventing them to
be seen as duplicate PVs.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJb2CAQAAoJELkRJDHlCQOf9pMP/0QfI9y8xYxzrtvnMhErb/us
FBdhgIxMEWkjcs48bY00DQLDWBgxTfngWeU2i01a64yNfo092JEa+UeOel/43KsV
cxE9pYK9JyQNak8sXjNXZm2ldUYlkgenEDdw4CF3PEkEmyukdbUicwFE8pAr1bdt
ntxG8qWD7mxekurO9ybCZ9Sjhhl6ZwCxuJxfGpYmSLQYmubL5JDGUGRnSo6Xjv9l
CxhJ1yhwR0oSBdleH4OHA7zdu+9+12fDt0JQRTXYAGUo0oZXOtzcrboudbp3G5RB
I2F4e1cmDShb7nommHF0gaWvzcw1gHuuSGdyVHn4EkEGk8XHVyKTbmadbJNru9pj
pmHmX6e3+8gIP3h14QNq+KP4poHQBCCqMsdjbCv9ay1+85v4i1xPUkA20Cgc/KLA
S1oWSOAKk6o44bETBwhYNmM03oMtnSdqYDo7rsIT9Qmtd6+/Aeda32Zj4RM9z+Eb
NZx21xQ6V+N7d02GmT1Z1XN7BgYBuEzm7iQtmm5TvZBBqcqjC1g3TF8oltUW/ALA
dt/H1V5VBZGqA4yu8vPMHwn4PSAW/gh9UFET5obfxWyyBRjFDkM4wBYe5LoovwW9
fG/Bty7u8+LIgyUb/GMUBPtoPOnXCyDHeZ3CBz4BmlASMHqxEi9aap4PBiwpY48I
Jq8hEGpeAjv/vVo80xXT
=Zp35
-----END PGP SIGNATURE-----

Bryn M. Reeves (1):
      dmsetup: fix error propagation in _display_info_cols()

David Teigland (12):
      lvconvert: restrict command matching for no option variant
      lvconvert: improve text about splitmirrors
      vgcreate: close exclusive fd after pvcreate
      mirrors: fix read_only_volume_list
      bcache: reduce MAX_IO to 256
      lvmetad: improve scan for pvscan all
      lvmetad: fix pvs for many devices
      WHATS_NEW: recent fixes
      scan: use full md filter when md 1.0 devices are present
      scan: enable full md filter when md 1.0 devices are present
      tests: add new test for lvm on md devices
      metadata: prevent writing beyond metadata area

Heinz Mauelshagen (8):
      lvconvert: reject conversions of LVs under snapshot
      lvconvert: reject conversions on raid1 split trackchanges SubLVs
      lvconvert: reject conversions on raid1 split trackchanges LVs
      lvconvert: fix regression preventing direct striped conversion
      lvconvert: fix conversion attempts to linear
      test: add striped -> raid0 test script
      lvconvert: avoid superfluous interim raid type
      lvconvert: fix interim segtype regression on raid6 conversions

Marian Csontos (15):
      post-release
      test: Check flavour is used and exists
      Add BSD 2-Clause License
      WHATS_NEW
      build: make generate
      pre-release
      pre-release
      post-release
      Merge branch '2018-06-01-stable' of git://sourceware.org/git/lvm2 into 2018-06-01-stable
      spec: Add vdo plugin for dmeventd
      spec: Disable python bindings on newer versions
      Update WHATS_NEW
      spec: Fix python and applib interactions
      Update WHATS_NEW
      pre-release

Peter Rajnoha (1):
      scripts: add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service

Zdenek Kabelac (8):
      dmeventd: base vdo plugin
      dmeventd: rebase to stable branch
      cache: drop metadata_format validation
      mirror: fix splitmirrors for mirror type
      tests: splitmirror for mirror type
      tests: check policy mq can be used with format2
      dmeventd: lvm2 plugin uses envvar registry
      tests: check activation of many thin-pool


