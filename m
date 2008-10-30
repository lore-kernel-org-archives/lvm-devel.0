From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 30 Oct 2008 18:16:35 +0000
Subject: Source code repository changes
Message-ID: <20081030181635.GS31233@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have begun merging the device-mapper part of the dm repository into
the lvm2 one.

In future there'll probably be only a single tarball release containing
both lvm2 and device-mapper userspace code.

I'll retain makefile targets that only build/install device-mapper for
those that do not need lvm2.

During the merging, CVS users might need to take fresh checkouts of the tree
as I shall be moving things around in an attempt to retain some file history.
I have no idea whether the git import script will cope, but there should
probably be a fresh import made once the process is complete.

I also intend to drop the debian and 2.4 kernel directories as nobody has been
maintaining them.

Alasdair
-- 
agk at redhat.com


