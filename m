From: Jim Meyering <jim@meyering.net>
Date: Tue, 24 Jul 2007 23:16:51 +0200
Subject: git mirror in the works: first step: user-map
Message-ID: <87tzrtjyd8.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm setting up a git mirror of the lvm2 cvs repository.  The first step is to
create a user-map file mapping the user names used in cvs commit messages
to the ("User Name", <user-email@example.com>) pair that git records.
Here's my first cut:

  agk=Alasdair Kergon <agk@redhat.com>
  akergon=Alasdair Kergon <agk@redhat.com>
  alewis=AJ Lewis <alewis@redhat.com>
  lewis=AJ Lewis <alewis@redhat.com>
  amanthei=Adam Manthei <amanthei@redhat.com>
  blutgens=Ben Lutgens <blutgens@sistina.com>
  bmr=Bryn M. Reeves <breeves@redhat.com>
  caulfield=Patrick Caulfield <pcaulfie@redhat.com>
  pcaulfield=Patrick Caulfield <pcaulfie@redhat.com>
  dilinger=Andres Salomon <dilinger@voxel.net>
  jbrassow=Jonathan Earl Brassow <jbrassow@redhat.com>
  mauelshagen=Heinz Mauelshagen <heinzm@redhat.com>
  mbroz=Milan Broz <mbroz@redhat.com>
  meyering=Jim Meyering <jim@meyering.net>
  mornfall=Petr Rockai <prokai@redhat.com>
  steve=
  thornber=Joe Thornber <joe@fib011235813.fsnet.co.uk>
  wysochanski=Dave Wysochanski <dwysocha@redhat.com>

Who is "steve"?

If you know of a preferred email address or different name
or spelling for any of the above, please let me know.

FYI, the git repository will be sync'd once or twice (it's efficient)
per hour from cvs, and will otherwise be read-only.


