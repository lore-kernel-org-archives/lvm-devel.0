From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 25 Jun 2014 00:53:15 +0100
Subject: LVM2 release 2.02.107: New argument --select
Message-ID: <20140624235315.GA28564@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Release 2.02.107 is available.

   ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.107.tgz
   ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.107.tgz.asc
   ftp://sources.redhat.com/pub/lvm2/WHATS_NEW
   ftp://sources.redhat.com/pub/lvm2/WHATS_NEW_DM

The most important new feature is a new command line argument:
  --select (or -S)

This lets you apply selection criteria to the output of reporting
commands.  We'll add it to commands that change things in a future
release.

A simple example:
  pvs -S 'free > 100M, name =~ sd' 
shows only PVs with more than 100M of free space and with the string
'sd' in their name.

Use '-S help' for a brief summary of the fields and operators or
look at the man pages for a little more detail.

Recall that -o lets you choose the fields to display, -O controls
the sort order and --noheadings, --separator, --rows, --nameprefixes,
--units and --nosuffix offer some alternative forms of output to help
you to write different types of scripts.

For debugging, or in scripts, use -o+selected to see all the output
as before but with a new column that indicates whether or not each
row meets your selection criteria.

We also plan to split out new fields from the various 'attribute' fields
to simplify access to the information they contain.

'dmsetup info -c' also accepts -S.

                         -------------

The LVM SSD caching support in this release remains experimental and can
be enabled using:

  configure --with-cache=internal
 

I'd also like to mention that there have been several extensions to
dumpconfig and profiles recently to help you to manage LVM
configuration.   (See the man pages.)

Alasdair


