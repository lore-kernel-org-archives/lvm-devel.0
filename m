From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Nov 2008 00:55:07 +0000
Subject: Re: Source code repository changes
Message-ID: <20081105005507.GH14593@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OK - I'd like packagers to start testing what is currently in LVM2 CVS and
report any problems with sets of configuration options / make targets actually
required.

Once the Fedora 11 tree opens (expected end of this week) I shall make the
first tarball release and use this code.

In summary:

  There'll be one source tarball instead of two.

  make device-mapper and make install_device-mapper will deal with the
device-mapper pieces.

  make and make install will do both.

Other make targets can deal with other useful combinations - some obvious ones
are still missing.

I have tried to retain file history during the import and added a dm_ prefix to
former device-mapper tags.

Fedora and RHEL will continue to ship three RPMS: device-mapper, lvm2 and lvm2-cluster,
but they'll all be generated from a single upstream tarball + SRPM.

Why are we doing this?
  - To avoid the time-wasting dependency problems when building two separate
    packages;
  - To switch to a single source repository to make a likely move from CVS to
    git easier;
  - To reduce the maintenance overhead;
  - To make sharing code between the two quicker and easier.

We'll maintain separate WHATS_NEW and VERSION files for now, but eventually I hope
to merge these too.

Alasdair
-- 
agk at redhat.com


