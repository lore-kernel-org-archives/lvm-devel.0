From: Petr Rockai <prockai@redhat.com>
Date: Sun, 30 Nov 2008 13:42:12 +0100
Subject: _vg_read() - meaning of consistent when PVs are missing in a VG
In-Reply-To: <1227674575.8335.83.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Tue, 25 Nov 2008 23:42:55 -0500")
References: <1227674575.8335.83.camel@localhost.localdomain>
Message-ID: <87y6z12xnf.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> Petr, with your recent changes, is the below to be expected?  Should
> _vg_read() return 'consistent = 0' if the VG has missing PVs?  If so, what is
> the meaning of 'consistent' now upon return from the function?  Does it mean
> "no LVs have missing PVs?"
consistent is pretty much overloaded, and I have never been quite sure what it
really means. However, with the current code, whether PVs are missing or not
does not influence the value of *consistent. It is still used for at least
failed auto-recoveries, or for cases where auto-recovery is forbidden.

> I wrote a little program to use the latest vg_read() APIs and was
> suprised when I called vg_read_for_update(cmd, vgname, NULL, 0) with a
> missing PV and got 'consistent = 1' on return, and vg_read_error()
> returned no error.  How will the app writer detect this if he wants to
> then lvcreate on the VG?  Are we missing an API or error condition?
You have vg_missing_pv_count. You generally don't need to care at all about
missing PVs in client code, unless you want to handle it specially. By default,
the library will refuse to write out a new version of the volume group if PVs
are missing.

If you need special handling of VGs with missing PVs, you can set
`cmd->handles_missing_pvs = 1`. At that point, all bets are off: the library
lets you write out new version of the VG. Currently, only lvremove and vgreduce
leverage this.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


