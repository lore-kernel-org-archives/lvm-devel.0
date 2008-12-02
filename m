From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 2 Dec 2008 02:40:07 +0000
Subject: [PATCH 1/4] Move guts of pvcreate into library area - prep for vgcreate.
In-Reply-To: <1228184768.3256.25.camel@localhost.localdomain>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<20081130042620.GF13235@agk.fab.redhat.com>
	<1228057068.3315.33.camel@localhost.localdomain>
	<20081201135915.GB26097@agk.fab.redhat.com>
	<1228184768.3256.25.camel@localhost.localdomain>
Message-ID: <20081202024007.GF26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 01, 2008 at 09:26:08PM -0500, Dave Wysochanski wrote:
> I don't see how this is possible.  Are you suggesting we split the
> validation into a separate API call(s), and let an app decide to call it
> or not?
 
There are two sorts of validation.

Optional validation and compulsory validation.

Compulsory validation covers anything that is required for internal LVM
consistency.  This must be built into the library calls and impossible
to bypass.

Optional validation covers everything else: the client of the library
is free to bypass it if it believes it knows what it is doing and
doesn't require it.  Roughly, this is what you get today with -ff -y.

Two current examples from pvcreate:

  Compulsory 
  - The device must not be in use currently (ie we can open it exclusively)

  Optional 
  - PV must not belong to an existing VG (ie we can destroy a VG if want to)

Alasdair
-- 
agk at redhat.com


