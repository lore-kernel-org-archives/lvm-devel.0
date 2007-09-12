From: Jim Meyering <jim@meyering.net>
Date: Wed, 12 Sep 2007 18:57:03 +0200
Subject: fix for link pthread-related link failure on Debian
Message-ID: <877imvsty8.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

FYI, I've just fixed in LVM the problem I fixed in device-mapper
not long ago: link failure (due to unsatisfied -lpthread references)
when building with --enable-static_link.  I noticed it on a Debian
unstable system.  The patch will show up here in a few minutes:

  http://git.et.redhat.com/?p=lvm2.git


