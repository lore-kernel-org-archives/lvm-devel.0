From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Nov 2008 16:44:21 +0100
Subject: [PATCH] (6/11) re-introduce vg_read
In-Reply-To: <1227499182.6608.20.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Sun, 23 Nov 2008 22:59:42 -0500")
References: <87abcm3qi3.fsf@eriador.mornfall.net>
	<1227499182.6608.20.camel@localhost.localdomain>
Message-ID: <87vdud6sdm.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> It is a little confusing have a vg_read_for_update() (only intended for
> WRITE) and a generic vg_read() (that allows both READ/WRITE) in the same
> API.  Should we have "vg_read_for_update()" (WRITE) and
> vg_read_for_query()" (READ) or something like that?
Well, is it? I tend to think about it like "select", and "select for update" in
SQL, although the analogy is not 100 % correct, I know. But I intended
vg_read_for_update as a convenience function that obviously points out that you
intend to update the VG (as opposed to just read it).

But, I suppose it's a bikeshed point. We however still want a generic vg_read,
for the iterator functions (in toollib) which need to pass a flag to
differentiate the read/write case.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


