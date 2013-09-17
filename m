From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 17 Sep 2013 11:02:47 -0400 (EDT)
Subject: lvm2 fixes
Message-ID: <alpine.LRH.2.02.1309171055210.21001@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

Here are links to various lvm2 fixes, not related to any specific work.

libdm: free strings:
http://people.redhat.com/mpatocka/patches/userspace/statistics/dm-free-values.patch

check sector number in dmsetup message:
https://www.redhat.com/archives/lvm-devel/2012-August/msg00032.html

lvm testsuite: Use #!/bin/bash:
https://www.redhat.com/archives/lvm-devel/2013-March/msg00004.html

lvm commandline: fix a possible number overflow:
http://people.redhat.com/mpatocka/patches/userspace/statistics/fix-strtol-underflow.patch

libdm: fix races with udev:
https://www.redhat.com/archives/lvm-devel/2013-September/msg00063.html

libdevmapper.h: make this include file standard-compliant:
https://www.redhat.com/archives/lvm-devel/2013-March/msg00058.html

Mikulas


