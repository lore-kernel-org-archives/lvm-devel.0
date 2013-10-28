From: Mikulas Patocka <mpatocka@redhat.com>
Date: Sun, 27 Oct 2013 20:54:16 -0400 (EDT)
Subject: [PATCH] New userspace statistics patch
Message-ID: <alpine.LRH.2.02.1310272051430.16136@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I announce a new version of userspace statistics patch. I put it here: 
http://people.redhat.com/~mpatocka/patches/userspace/statistics/lvstats.patch

A difference from the previous version: you can create statistics with 
arbitrary starting and ending sector. In the previous version you could 
only subdivide existing range.

Mikulas


