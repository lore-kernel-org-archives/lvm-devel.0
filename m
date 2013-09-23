From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 20:55:51 +0000 (UTC)
Subject: v2_02_102 annotated tag has been created
Message-ID: <20130923205551.439EC615EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a62a93f562f32e1c314e6d7a43eca51d51db4e5
Commit:        3a62a93f562f32e1c314e6d7a43eca51d51db4e5
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2013-09-23 14:50 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2013-09-23 14:50 +0000

annotated tag: v2_02_102 has been created
	    at 3a62a93f562f32e1c314e6d7a43eca51d51db4e5 (tag)
       tagging c8057aec36a3d00789b59e06a9ed9eeee7151ded (commit)
      replaces v2_02_101

Release 2.02.102

 18 files changed, 137 insertions(+), 203 deletions(-)

Essential fix for clvmd+corosync handling of cluster node failures.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABAgAGBQJSQFUzAAoJEK2W1qbAHj1nMaMP/0pwsnaGZ9J1wM7Q38VAV1W8
b+WI6kNO0TQTYpm0jCVtvtxYqJWPxm2F1UDcurnqZoHGAmAVP8WdSkySRt485NG7
FNWaA5Zi/kFcD2QE9ILR3KY3JUdjBKX4S5gCG6bZ215+p6OCE2AM6sD03bB5IUI6
BaxeQ4BHDtWD6u069z93eTi49rJtiyPQLPvO+5MQvysF0bROYX4UEicos5vgnnW0
ZvSJa6+Z2AeAbL+YY35AO3C7PJ/dBBShxJTSoDgiKH7CJnXDyPq5qFYLS9sjoZpG
9aLj94keP5ZuPGO2L++QeXU9LHKLcBE1fXvlS/Y4137/IvW2lNtj7C74+NhCkc3p
fcmucOrS09PML8CWseJYrYokdShAXH83wN4gby2OSlh+CbjwMiTsmmrgAytWO/Tk
NdySvoEAnRDOoWWzhdNhw5VkDiI/RKt6D267dsCB+PUFZcMuf7Ht4V5lXXwwywg2
AUZumWvyklI8qkL1KwnUnBUBoD7VZLUTS4YsBWoBUlJBEGAdRBwUVseusI461GYJ
MokvNXsG9+OwdWaKFEUiszO2fmELX7ErVeUSywxhR+s9pi4obLakVnRARY6hcJlK
YaMkPRpL5gDOGUWg5DKmUL/B4Z4mERicCmwSR7w0ElGNHHcBEiypfvBJAtYaGT5J
ZHgmIFoQXLArA8VADtMu
=QE5J
-----END PGP SIGNATURE-----

Alasdair G Kergon (1):
      release 2.02.102

Christine Caulfield (1):
      clvmd: Fix node up/down handing in corosync module

Jonathan Brassow (1):
      test: Blacklist fedora-19 kernel for RAID4/5/6 dev replace tests

Zdenek Kabelac (15):
      cleanup: monitoring more readable
      cleanup: skip call of detect...
      cleanup: release all memory in error path
      cleanup: shorter code
      cleanup: add log_error error path messages
      cleanup: drop unused report parameter
      dmeventd: simplify fifos init
      raid: add lv_is_raid()
      lvinfo: allow to use lv_info with NULL info
      activation: use improved lv_info
      Makefile: add missing deps
      tests: hide expected error message
      tests: fix typo VEROSE->VERBOSE in Makefile.in
      tests: drop pointeless test
      tests: drop extra loop


