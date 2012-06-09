From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 9 Jun 2012 01:23:08 +0100
Subject: LVM release 2.02.96 / git / veritysetup
Message-ID: <20120609002308.GD15806@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New LVM release
---------------
LVM version 2.02.96 is now available from
  ftp://sources.redhat.com/pub/lvm2/

and this is mirrored on the sites listed here:
  http://sourceware.org/mirrors.html

Lots of little enhancements and fixes this time.
For a summary:
  ftp://sources.redhat.com/pub/lvm2/WHATS_NEW_DM
  ftp://sources.redhat.com/pub/lvm2/WHATS_NEW


git
---
This release was done from a new git repository at:
  git://git.fedorahosted.org/git/lvm2.git
  http://git.fedorahosted.org/git/lvm2.git
  
The project web page should be up to date again with locations.
  http://sourceware.org/lvm2/

The CVS repository will no longer be updated.

veritysetup
-----------
Although this release contains a userspace tool for dm-verity,
  configure --with-verity-setup=<cryptlib>
we think the cryptsetup package would provide a better home for this
so watch out for an updated version in an upcoming cryptsetup release.

Alasdair

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 835 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120609/24ed3e11/attachment.sig>
