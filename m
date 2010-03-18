From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Mar 2010 15:52:34 -0500
Subject: [PATCH 0 of 12]: lvm mirrored log support
Message-ID: <1268945554.22303.4.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This round of patches fixes the latest issue articulated by Taka
regarding the need to repair a mirror's log before the mirror itself.
Additionally, it fixes the issues that remained when running the LVM
testsuite.  (The final patch introduces some additions to the testsuite
that do not pass, but this is because it tests '--alloc anywhere';
something that is being worked on separately from these patches.)  I did
have to change some of the tests in the testsuite, because I believe
they were performing their tests incorrectly (see the first two
patches).

 brassow



