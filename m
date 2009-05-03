From: Petr Rockai <prockai@redhat.com>
Date: Sun, 03 May 2009 18:37:00 +0200
Subject: LVM2/lib/metadata mirror.c
References: <20090423164302.11615.qmail@sourceware.org>
	<20090424003839.GC15019@agk.fab.redhat.com>
Message-ID: <87my9urvmb.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(I was pretty sure I have sent this one already, but I can't find it now on the
list... re-sending in case it got lost somewhere...)

Alasdair G Kergon <agk@redhat.com> writes:
> I'm not at all sure about this: what is your test case that requires the
> id_equal() check and fails without it?
The testcase is that the sought-for PV is a MISSING_PV. This happens when
trying to repair a mirror: we are looking for a PV to remove and we certainly
want the missing one to be found to be removable. But we can't use pv->dev for
checking that, since there is no device associated to a MISSING_PV. So I have
guessed that UUID is the next best thing.

> (Is there a danger it could match the wrong device, if, say, someone
> cloned a PV?)
If the reading code will allow us to proceed with dup PVs, then yes, this could
happen. However, it seems to me that lvmcache_add will throw away any such dup
PVs (in lvmcache.c) -- and even if that path is not invoked, vg_validate will
reject any VG with a dup PV in it. Hopefully, that is robust enough.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


