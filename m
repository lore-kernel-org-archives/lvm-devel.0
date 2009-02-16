From: Petr Rockai <prockai@redhat.com>
Date: Mon, 16 Feb 2009 23:10:12 +0100
Subject: [PATCH] Fix segfault when using vgsplit in stacked environment
In-Reply-To: <20090210181443.GB7582@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Tue, 10 Feb 2009 18:14:43 +0000")
References: <498FE109.6000103@redhat.com>
	<20090210181443.GB7582@agk.fab.redhat.com>
Message-ID: <87bpt211a3.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> I don't think the code should be getting as far as it does in that
> situation.

(explanation for the list) After an IRC discussion, we have agreed that a
different approach would work here, specifically, that we should not allow
tools to try tinkering with VGs that have PVs missing, unless they specifically
know what they are doing. There's probably half dozen other places where we
assume that `pv->dev` is valid. The attached patch changes the meaning of
`cmd->handles_missing_pvs` somewhat: If a tool now opens a VG *for writing* but
it does not set handles_missing_pvs, vg_read will fail.

This check was previously done only in vg_write, which led to situations like
the above bug, where a little less vigorous code path trips a NULL
pointer. This behaviour change of handles_missing_pvs affects these situations:

- lvchange -a, vgchange -a take a write lock, so they need to set, for the -a
  case, handles_missing_pvs. This is safe.
- vgreduce needs to set handles_missing_pvs, since it is supposed to work in
  that situation... it previously did not need the flag in general, since it
  most of the time writes out a VG that has no PVs missing in it; however,
  since it's now needed also for opening the VG for writing, this needs to be
  always set for --removemissing; there's a small risk of bugs associated, but
  it can be mitigated by adding appropriate check to the code...

Please note that this patch depends on the "vg_read" patchset found elsewhere
on this list.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-vg_read-missing_pvs.diff
Type: text/x-diff
Size: 4043 bytes
Desc: lvm-vg_read-missing_pvs.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090216/47777170/attachment.bin>
-------------- next part --------------

PS: The patch passes the testsuite and also makes Milan's testcase pass (it is
included with the patch).

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
