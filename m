From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Jul 2010 14:01:31 +0100
Subject: LVM fault handling policies
In-Reply-To: <459C937F-B3C8-4E8D-8894-AA97F0AB8E2B@redhat.com>
References: <459C937F-B3C8-4E8D-8894-AA97F0AB8E2B@redhat.com>
Message-ID: <20100702130130.GJ23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 01, 2010 at 03:22:20PM -0500, Jon Brassow wrote:
> Note, while most LVM commands
> will automatically update the metadata on a restored devices, the
> following exceptions exist:
> - pvs (because it does not read/update VG metadata)
 
It depends what fields have been requested to be displayed:
some are stored in the VG metadata so have to be read from there.

> (a 'dmsetup suspend/resume' works equally well).  

Let's not encourage use of dmsetup alongside LVM tools - all sorts of
other things can go wrong then.  If it's a useful thing to be able to
do, lvm should offer it in a properly-controlled way.  (lvchange
--refresh?)

> before proceeding.  This is simply another case, I think, where it

Avoid writing it as a personal opinion:)  Write it in the form of
an option to consider.

Alasdair


