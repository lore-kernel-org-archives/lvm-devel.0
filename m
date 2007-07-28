From: Jim Meyering <jim@meyering.net>
Date: Sat, 28 Jul 2007 15:07:18 +0200
Subject: unofficial git mirror of LVM2 and device-mapper CVS repositories
Message-ID: <87odhwwubd.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've set up an automatically-sync'd git mirror for each of the
device-mapper and LVM2 cvs repositories.  Each mirror is updated
approximately every 15 minutes.  You can view the summaries via these
URLs:

    http://git.et.redhat.com/?p=lvm2.git
    http://git.et.redhat.com/?p=device-mapper.git

You can get a copy of either repository like this:
(this uses the efficient "git://" protocol, and is sort of
analogous to CVS pserver, i.e. anonymous, for read-only access)

    git clone git://et.redhat.com/lvm2
    git clone git://et.redhat.com/device-mapper

They're not big, just 6.6MB and 6.1MB respectively, yet
each contains the entire revision history for its project.
[For the record, each size above include a checked out copy of the
 sources as well as the ".git" repository.  Each repository itself
 is only 20-25% the size of the corresponding CVS repository. ]

Note, if you're new to "git", you typically do the "git clone" only
once, initially, and from then on, you "cd" into the directory and
download/merge the latest sources via "git pull".

Also, for now, these two repository mirrors are no more than a
personal project/service that I find useful.  Eventually, they may
be classified as "supported", but perhaps via a different host, e.g.,
git.fedoraproject.org.  If/when anything changes, I'll announce it here.


