From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed,  2 Dec 2009 14:49:32 -0500
Subject: [PATCH 0/2] Fix setting of readahead in lvcreate, add tests.
Message-ID: <1259783374-16394-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


These two patches fix lvcreate to honor --readahead and add some
tests.  Not sure but somewhere along the line this got broken
and default was all you ever got.  Second patch adds some tests
to prevent this in the future.  Found this problem while reviewing
replicator patches.


