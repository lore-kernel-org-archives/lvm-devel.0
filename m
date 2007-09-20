From: Jim Meyering <jim@meyering.net>
Date: Thu, 20 Sep 2007 22:44:12 +0200
Subject: NEW git mirrors of the lvm2 and device-mapper CVS repositories
Message-ID: <87zlzhf4o3.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

You may recall that I set up git mirrors of the lvm2 and
device-mapper CVS repositories:

    http://thread.gmane.org/gmane.linux.kernel.device-mapper.devel/3758

The repositories mentioned there will continue to work indefinitely,
but now, there are new, more reliable ones.  They're hosted on the
same system as the CVS repositories:

    git-clone git://sources.redhat.com/git/dm
    http://sources.redhat.com/git/gitweb.cgi?p=dm.git

    git-clone git://sources.redhat.com/git/lvm2
    http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git

Thanks to Frank Ch. Eigler for setting up for git service
on sources.redhat.com (aka sourceware.org).


